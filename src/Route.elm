module Route exposing
    ( Features
    , HomeParams
    , LegacyHomeParams
    , Route(..)
    , defaultParams
    , flagParam
    , fromLegacyParams
    , href
    , ifFeature
    , params
    , parse
    , parseFeatures
    , stringify
    )

import Html as H
import Html.Attributes as A
import Http
import Maybe.Extra
import Regex
import Set as Set exposing (Set)
import Url as Url exposing (Url)
import Url.Parser as P exposing ((</>), (<?>))
import Url.Parser.Query as Q


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


fromLegacyParams : String -> LegacyHomeParams -> HomeParams
fromLegacyParams version args =
    { version = version
    , hero = args.hero
    , build = args.build
    , search = args.search
    }


defaultParams : String -> HomeParams
defaultParams version =
    fromLegacyParams version homeParams0


params : Route -> Maybe HomeParams
params route =
    case route of
        Home args ->
            Just args

        Stats args ->
            Just args

        StatsTSV args ->
            Just args

        _ ->
            Nothing


homeParams0 : LegacyHomeParams
homeParams0 =
    { hero = "helpfulAdventurer"
    , build = Nothing
    , search = Nothing
    }


type Route
    = Home HomeParams
    | Stats HomeParams
    | StatsTSV HomeParams
    | Changelog
    | NotFound
    | Root LegacyHomeParams
    | LegacyHome LegacyHomeParams


type alias Features =
    -- { fancyTooltips : Bool }
    {}


features0 : Features
features0 =
    -- { fancyTooltips = True }
    {}


parse : Url -> Route
parse =
    hashUrl
        >> P.parse parser
        >> Maybe.withDefault NotFound
        >> Debug.log "navigate to"


hashUrl : Url -> Url
hashUrl url =
    -- elm 0.19 removed parseHash; booo. This function fakes it by transforming
    -- `https://example.com/?flag=1#/some/path?some=query` to
    -- `https://example.com/some/path?flag=1&some=query` for the parser.
    case url.fragment |> Maybe.withDefault "" |> String.split "?" of
        path :: queries ->
            let
                query =
                    queries |> String.join "?"

                urlQuery =
                    url.query |> Maybe.Extra.unwrap "" (\s -> s ++ "&")
            in
            { url | path = path, query = urlQuery ++ query |> Just }

        [] ->
            { url | path = "", query = url.query }


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
        <?> Q.string "q"


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
        , P.map Home <| P.map (\v -> HomeParams v homeParams0.hero Nothing) <| homeQS <| P.s "g" </> encodedString
        , P.map Home <| P.map (\v h -> HomeParams v h Nothing) <| homeQS <| P.s "g" </> encodedString </> P.string

        -- a modern versioned url, with build
        , P.map Home <| P.map HomeParams <| homeQS <| P.s "g" </> encodedString </> P.string </> maybeString

        -- other non-skilltree urls.
        , P.map Stats <| P.map HomeParams <| homeQS <| P.s "s" </> encodedString </> P.string </> maybeString
        , P.map Stats <| P.map (\v h -> HomeParams v h Nothing) <| homeQS <| P.s "s" </> encodedString </> P.string
        , P.map StatsTSV <| P.map HomeParams <| homeQS <| P.s "tsv" </> encodedString </> P.string </> maybeString
        , P.map StatsTSV <| P.map (\v h -> HomeParams v h Nothing) <| homeQS <| P.s "tsv" </> encodedString </> P.string
        , P.map Changelog <| P.s "changelog"
        ]


encodedString =
    -- if the string doesn't decode, skip decoding and use it as-is
    P.custom "ENCODED_STRING" (\s -> Url.percentDecode s |> Maybe.withDefault s |> Just)


falseBools =
    Set.fromList [ "", "0", "no", "n", "false" ]


{-| bool param with a default value
-}
flagParam : String -> Bool -> Q.Parser Bool
flagParam name default =
    let
        parseFlag strs =
            case strs of
                [] ->
                    default

                str :: _ ->
                    Set.member (str |> String.toLower) falseBools |> not
    in
    Q.custom name parseFlag


parseFeatures : Url -> Features
parseFeatures =
    hashUrl
        -- parser expects no segments
        >> (\url -> { url | path = "", fragment = Nothing })
        >> P.parse featuresParser
        >> Maybe.withDefault features0
        >> Debug.log "feature-flags: "


featuresParser : P.Parser (Features -> a) a
featuresParser =
    P.map Features <|
        -- <?> flagParam "enableFancyTooltips" features0.fancyTooltips
        P.top


ifFeature : Bool -> a -> a -> a
ifFeature pred t f =
    if pred then
        t

    else
        f


encode : String -> String
encode =
    Url.percentEncode >> String.replace "(" "%28" >> String.replace ")" "%29"


stringifyHomePath : HomeParams -> String
stringifyHomePath { version, hero, build, search } =
    let
        qs =
            -- in addition to normal escaping, replace parens so urls and markdown don't break
            Maybe.Extra.unwrap "" (encode >> (++) "?q=") search
    in
    "/"
        ++ encode version
        ++ (case ( hero, build ) of
                -- ( "helpfulAdventurer", Nothing ) ->
                -- qs
                ( _, Nothing ) ->
                    "/" ++ hero ++ qs

                ( _, Just b ) ->
                    "/" ++ hero ++ "/" ++ b ++ qs
           )


stringify : Route -> String
stringify route =
    case route of
        Home args ->
            "#/g" ++ stringifyHomePath args

        Stats args ->
            "#/s" ++ stringifyHomePath args

        StatsTSV args ->
            "#/tsv" ++ stringifyHomePath args

        Changelog ->
            "#/changelog"

        NotFound ->
            Debug.todo "why are you stringifying Route.NotFound?"

        _ ->
            Debug.todo "I refuse to stringify legacy urls" route


href : Route -> H.Attribute msg
href =
    stringify >> A.href
