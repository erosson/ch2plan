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
    { version : String
    , hero : String
    , build : Maybe String
    , search : Maybe String
    }


type alias LegacyHomeParams =
    { hero : String
    , build : Maybe String
    , search : Maybe String
    }


delegacy : String -> LegacyHomeParams -> HomeParams
delegacy version params =
    { version = version
    , hero = params.hero
    , build = params.build
    , search = params.search
    }


homeParams0 : LegacyHomeParams
homeParams0 =
    { hero = "helpfulAdventurer"
    , build = Nothing
    , search = Nothing
    }


type Route
    = Home HomeParams
    | Changelog
    | NotFound
    | Root LegacyHomeParams
    | LegacyHome LegacyHomeParams


type alias Features =
    { fancyTooltips : Bool, fullscreen : Bool, importSave : Bool }


features0 : Features
features0 =
    { fancyTooltips = False, fullscreen = False, importSave = False }


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


parser : P.Parser (Route -> a) a
parser =
    P.oneOf
        -- the skilltree has a few different urls. Root, "/"...
        [ P.map Root <| P.map (LegacyHomeParams homeParams0.hero Nothing) <| homeQS <| P.top

        -- an old legacy build, back when we only supported Cid: "/b/1&2&3&4&5"
        , P.map LegacyHome <| P.map (LegacyHomeParams homeParams0.hero) <| homeQS <| P.s "b" </> maybeString

        -- an old/legacy empty versionless build: "/h/helpfulAdventurer"...
        , P.map LegacyHome <| P.map (\h -> LegacyHomeParams h Nothing) <| homeQS <| P.s "h" </> P.string

        -- a non-empty versionless build: "/h/helpfulAdventurer/1&2&3&4&5"...
        , P.map LegacyHome <| P.map LegacyHomeParams <| homeQS <| P.s "h" </> P.string </> maybeString

        -- a modern versioned url, no build
        , P.map Home <| P.map (\v -> HomeParams v homeParams0.hero Nothing) <| homeQS <| P.s "g" </> P.string
        , P.map Home <| P.map (\v h -> HomeParams v h Nothing) <| homeQS <| P.s "g" </> P.string </> P.string

        -- a modern versioned url, with build
        , P.map Home <| P.map HomeParams <| homeQS <| P.s "g" </> P.string </> P.string </> maybeString

        -- other urls.
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
            <?> flagParam "enableFancyTooltips" features0.fancyTooltips
            <?> flagParam "enableFullscreen" features0.fullscreen
            <?> flagParam "enableImportSave" features0.importSave


ifFeature : Bool -> a -> a -> a
ifFeature pred t f =
    if pred then
        t
    else
        f


stringify : Route -> String
stringify route =
    case route of
        Home { version, hero, build, search } ->
            let
                qs =
                    Maybe.Extra.unwrap "" ((++) "?q=" << Http.encodeUri) search
            in
                "#/g/"
                    ++ version
                    ++ case ( hero, build ) of
                        -- ( "helpfulAdventurer", Nothing ) ->
                        -- qs
                        ( _, Nothing ) ->
                            "/" ++ hero ++ qs

                        ( _, Just b ) ->
                            "/" ++ hero ++ "/" ++ b ++ qs

        Changelog ->
            "#/changelog"

        NotFound ->
            Debug.crash "why are you stringifying Route.NotFound?"

        _ ->
            Debug.crash "I refuse to stringify legacy urls" route


href : Route -> H.Attribute msg
href =
    stringify >> A.href
