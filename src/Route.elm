module Route exposing (..)

import Navigation
import UrlParser as P exposing ((</>), (<?>))
import Regex


type alias HomeParams =
    { build : Maybe String }


type Route
    = Home HomeParams


parse : Navigation.Location -> Route
parse =
    hashQS
        >> P.parseHash parser
        >> Maybe.withDefault (Home { build = Nothing })
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
        [ P.map (Home { build = Nothing }) P.top
        , P.map Home <| P.map HomeParams <| P.s "b" </> maybeString
        ]


stringify : Route -> String
stringify route =
    case route of
        Home { build } ->
            case build of
                Nothing ->
                    "#/"

                Just b ->
                    "#/b/" ++ b
