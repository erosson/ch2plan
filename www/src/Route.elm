module Route exposing
    ( Features
    , HomeParams
    , Route(..)
    , defaultParams
    , flagParam
    , href
    , ifFeature
    , legacyVersion
    , liveVersion
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
import Set exposing (Set)
import Url exposing (Url)
import Url.Builder as B
import Url.Parser as P exposing ((</>), (<?>))
import Url.Parser.Query as Q


type alias HomeParams =
    { version : String
    , hero : String
    , build : Maybe String
    , search : Maybe String
    }


legacyVersion : String
legacyVersion =
    "0.052-beta"


liveVersion : String
liveVersion =
    "0.13.0-r490"


defaultHero =
    "helpfulAdventurer"


defaultParams : String -> HomeParams
defaultParams version =
    { version = version
    , hero = defaultHero
    , build = Nothing
    , search = Nothing
    }


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


type Route
    = Redirect Route
    | Home HomeParams
    | Stats HomeParams
    | StatsTSV HomeParams
    | EthItems
    | Changelog
    | Runecorder (Maybe String)


type alias Features =
    { transcendNodes : Bool }


features0 : Features
features0 =
    { transcendNodes = False }


parse : Url -> Maybe Route
parse =
    hashUrl >> P.parse parser


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
        [ P.map Redirect <| P.map Home <| P.map (HomeParams liveVersion defaultHero Nothing) <| homeQS <| P.top

        -- an old legacy build, back when we only supported Cid: "/b/1&2&3&4&5"
        , P.map Redirect <| P.map Home <| P.map (HomeParams legacyVersion defaultHero) <| homeQS <| P.s "b" </> maybeString

        -- an old/legacy empty versionless build: "/h/helpfulAdventurer"...
        , P.map Redirect <| P.map Home <| P.map (\h -> HomeParams legacyVersion h Nothing) <| homeQS <| P.s "h" </> P.string

        -- a legacy non-empty versionless build: "/h/helpfulAdventurer/1&2&3&4&5"...
        , P.map Redirect <| P.map Home <| P.map (HomeParams legacyVersion) <| homeQS <| P.s "h" </> P.string </> maybeString

        -- convenience redirect from a heroless url: "/g/0.12.0"
        , P.map Redirect <| P.map Home <| P.map (\v -> HomeParams v defaultHero Nothing) <| homeQS <| P.s "g" </> encodedString

        -- a modern versioned url, no build
        , P.map Home <| P.map (\v h -> HomeParams v h Nothing) <| homeQS <| P.s "g" </> encodedString </> P.string

        -- a modern versioned url, with build
        , P.map Home <| P.map HomeParams <| homeQS <| P.s "g" </> encodedString </> P.string </> maybeString

        -- other non-skilltree urls.
        , P.map Stats <| P.map HomeParams <| homeQS <| P.s "s" </> encodedString </> P.string </> maybeString
        , P.map Stats <| P.map (\v h -> HomeParams v h Nothing) <| homeQS <| P.s "s" </> encodedString </> P.string
        , P.map StatsTSV <| P.map HomeParams <| homeQS <| P.s "tsv" </> encodedString </> P.string </> maybeString
        , P.map StatsTSV <| P.map (\v h -> HomeParams v h Nothing) <| homeQS <| P.s "tsv" </> encodedString </> P.string
        , P.map EthItems <| P.s "ethitems"
        , P.map Changelog <| P.s "changelog"
        , P.map Runecorder <| P.s "runecorder" <?> Q.string "body"
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


featuresParser : P.Parser (Features -> a) a
featuresParser =
    P.map Features <|
        P.top
            <?> flagParam "enableTranscendNodes" features0.transcendNodes


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
        Redirect r ->
            stringify r

        Home args ->
            "#/g" ++ stringifyHomePath args

        Stats args ->
            "#/s" ++ stringifyHomePath args

        StatsTSV args ->
            "#/tsv" ++ stringifyHomePath args

        Changelog ->
            "#/changelog"

        EthItems ->
            "#/ethitems"

        Runecorder body ->
            "#/runecorder" ++ B.toQuery (List.filterMap identity [ Maybe.map (B.string "body") body ])


href : Route -> H.Attribute msg
href =
    stringify >> A.href
