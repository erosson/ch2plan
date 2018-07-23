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
    { hero : String, build : Maybe String, search : Maybe String }


homeParams0 : HomeParams
homeParams0 =
    { hero = "helpfulAdventurer", build = Nothing, search = Nothing }


type Route
    = Home HomeParams
    | Changelog
    | NotFound


type alias Features =
    { multiSelect : Bool, zoom : Bool }


features0 : Features
features0 =
    { multiSelect = True, zoom = True }


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


parser : P.Parser (Route -> a) a
parser =
    P.oneOf
        [ P.map Home <| P.map (HomeParams homeParams0.hero Nothing) <| P.top <?> P.stringParam "q"
        , P.map Home <| P.map (\h -> HomeParams h Nothing) <| P.s "h" </> P.string <?> P.stringParam "q"
        , P.map Home <| P.map HomeParams <| P.s "h" </> P.string </> maybeString <?> P.stringParam "q"

        -- legacy builds, back when Cid was the only hero
        , P.map Home <| P.map (HomeParams homeParams0.hero) <| P.s "b" </> maybeString <?> P.stringParam "q"
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
