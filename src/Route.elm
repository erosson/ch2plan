module Route exposing (..)

import Set as Set exposing (Set)
import Navigation
import UrlParser as P exposing ((</>), (<?>))
import Regex
import Html as H
import Html.Attributes as A


type alias HomeParams =
    { hero : String, build : Maybe String }


homeParams0 =
    { hero = "helpfulAdventurer", build = Nothing }


type Route
    = Home HomeParams
    | Changelog
    | NotFound


type alias Features =
    { multiSelect : Bool, zoom : Bool }


features0 : Features
features0 =
    { multiSelect = False, zoom = False }


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
        [ P.map (Home homeParams0) P.top
        , P.map Home <| P.map (\h -> HomeParams h Nothing) <| P.s "h" </> P.string
        , P.map Home <| P.map HomeParams <| P.s "h" </> P.string </> maybeString

        -- legacy builds, back when Cid was the only hero
        , P.map Home <| P.map (HomeParams "helpfulAdventurer") <| P.s "b" </> maybeString
        , P.map Changelog <| P.s "changelog"
        ]


falseBools =
    Set.fromList [ "", "0", "no", "n", "false" ]


boolParam : String -> P.QueryParser (Bool -> a) a
boolParam name =
    Maybe.withDefault ""
        >> String.toLower
        >> (flip Set.member) falseBools
        >> not
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
            <?> boolParam "enableMultiSelect"
            <?> boolParam "enableZoom"


ifFeature : Bool -> a -> a -> a
ifFeature pred t f =
    if pred then
        t
    else
        f


stringify : Route -> String
stringify route =
    case route of
        Home { hero, build } ->
            case ( hero, build ) of
                ( "helpfulAdventurer", Nothing ) ->
                    "#/"

                ( _, Nothing ) ->
                    "#/h/" ++ hero

                ( _, Just b ) ->
                    "#/h/" ++ hero ++ "/" ++ b

        Changelog ->
            "#/changelog"

        NotFound ->
            Debug.crash "why are you stringifying Route.NotFound?"


href : Route -> H.Attribute msg
href =
    stringify >> A.href