module Route exposing (..)

import Set as Set exposing (Set)
import Navigation
import UrlParser as P exposing ((</>), (<?>))
import Regex
import Html as H
import Html.Attributes as A
import Http
import Maybe.Extra


type alias HomeParams =
    { hero : String
    , build : Maybe String
    , search : Maybe String

    -- Hue rotation for these node colors, for accessibility.
    -- https://github.com/erosson/ch2plan/issues/33
    , hueSelected : Maybe Int
    , hueSearch : Maybe Int
    }


homeParams0 : HomeParams
homeParams0 =
    { hero = "helpfulAdventurer"
    , build = Nothing
    , search = Nothing
    , hueSelected = Nothing
    , hueSearch = Nothing
    }


type Route
    = Home HomeParams
    | Changelog
    | NotFound


type alias Features =
    { multiSelect : Bool, zoom : Bool, fancyTooltips : Bool, fullscreen : Bool }


features0 : Features
features0 =
    { multiSelect = True, zoom = True, fancyTooltips = False, fullscreen = False }


parse : Navigation.Location -> Route
parse =
    hashQS
        >> P.parseHash parser
        >> Maybe.withDefault NotFound
        >> Debug.log "navigate to"


hashQS : Navigation.Location -> Navigation.Location
hashQS loc =
    -- UrlParser doesn't do ?query=strings in the #hash, so fake it using the non-hash querystring
    case Regex.split (Regex.AtMost 1) (Regex.regex "\\?") loc.hash of
        [ hash ] ->
            { loc | search = loc.search }

        [ hash, qs ] ->
            { loc | hash = hash, search = loc.search ++ "&" ++ qs }

        [] ->
            Debug.crash "hashqs: empty"

        other ->
            Debug.crash "hashqs: 3+"


maybeString =
    P.string
        |> P.map
            (\s ->
                if s == "" then
                    Nothing
                else
                    Just s
            )


homeQS path =
    -- Query string for all skill tree urls
    path
        <?> P.stringParam "q"
        <?> P.intParam "hueSelected"
        <?> P.intParam "hueSearch"


parser : P.Parser (Route -> a) a
parser =
    P.oneOf
        -- the skilltree has a few different urls. Root, "/"...
        [ P.map Home <| P.map (HomeParams homeParams0.hero Nothing) <| homeQS <| P.top

        -- an empty build: "/h/helpfulAdventurer"...
        , P.map Home <| P.map (\h -> HomeParams h Nothing) <| homeQS <| P.s "h" </> P.string

        -- a non-empty build: "/h/helpfulAdventurer/1&2&3&4&5"...
        , P.map Home <| P.map HomeParams <| homeQS <| P.s "h" </> P.string </> maybeString

        -- and a non-empty legacy build, back when we only supported Cid: "/b/1&2&3&4&5"
        , P.map Home <| P.map (HomeParams homeParams0.hero) <| homeQS <| P.s "b" </> maybeString
        , P.map Changelog <| P.s "changelog"
        ]


falseBools =
    Set.fromList [ "", "0", "no", "n", "false" ]


{-| bool param with a default value
-}
flagParam : String -> Bool -> P.QueryParser (Bool -> a) a
flagParam name default =
    Maybe.Extra.unwrap default (String.toLower >> (flip Set.member) falseBools >> not)
        |> P.customParam name


parseFeatures : Navigation.Location -> Features
parseFeatures =
    hashQS
        -- parser expects no segments
        >> (\loc -> { loc | hash = "" })
        >> P.parseHash featuresParser
        >> Maybe.withDefault features0
        >> Debug.log "feature-flags: "


featuresParser : P.Parser (Features -> a) a
featuresParser =
    P.map Features <|
        P.top
            <?> flagParam "enableMultiSelect" features0.multiSelect
            <?> flagParam "enableZoom" features0.zoom
            <?> flagParam "enableFancyTooltips" features0.fancyTooltips
            <?> flagParam "enableFullscreen" features0.fullscreen


ifFeature : Bool -> a -> a -> a
ifFeature pred t f =
    if pred then
        t
    else
        f


stringify : Route -> String
stringify route =
    case route of
        Home { hero, build, search } ->
            let
                qs =
                    Maybe.Extra.unwrap "" ((++) "?q=" << Http.encodeUri) search
            in
                case ( hero, build ) of
                    ( "helpfulAdventurer", Nothing ) ->
                        "#/" ++ qs

                    ( _, Nothing ) ->
                        "#/h/" ++ hero ++ qs

                    ( _, Just b ) ->
                        "#/h/" ++ hero ++ "/" ++ b ++ qs

        Changelog ->
            "#/changelog"

        NotFound ->
            Debug.crash "why are you stringifying Route.NotFound?"


href : Route -> H.Attribute msg
href =
    stringify >> A.href
