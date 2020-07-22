module RouteTest exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Route exposing (Route)
import Test exposing (..)
import Url as Url exposing (Url)
import Url.Parser as P exposing ((<?>))


flagParser : Bool -> Url -> Maybe Bool
flagParser default =
    P.parse <| P.top <?> Route.flagParam "enableTest" default


flags : Test
flags =
    describe "flagParam"
        [ test "default false, flag false" <| \_ -> Expect.equal (Just False) <| flagParser False { loc | query = Just "enableTest=0" }
        , test "default false, flag true" <| \_ -> Expect.equal (Just True) <| flagParser False { loc | query = Just "enableTest=1" }
        , test "default false, flag missing" <| \_ -> Expect.equal (Just False) <| flagParser False { loc | query = Just "" }
        , test "default false, flag value-empty" <| \_ -> Expect.equal (Just False) <| flagParser False { loc | query = Just "enableTest=" }
        , test "default false, flag value-missing" <| \_ -> Expect.equal (Just False) <| flagParser False { loc | query = Just "enableTest" }
        , test "default true, flag false" <| \_ -> Expect.equal (Just False) <| flagParser True { loc | query = Just "enableTest=0" } -- this is the tricky one!
        , test "default true, flag true" <| \_ -> Expect.equal (Just True) <| flagParser True { loc | query = Just "enableTest=1" }
        , test "default true, flag missing" <| \_ -> Expect.equal (Just True) <| flagParser True { loc | query = Just "" }
        ]


urlFromPath : String -> Url
urlFromPath s =
    case Url.fromString s of
        Just url ->
            url

        Nothing ->
            -- allowed in tests!
            Debug.todo <| "invalid url: " ++ s


parse : String -> Maybe Route
parse =
    (++) "https://example.com" >> urlFromPath >> Route.parse


legacy : Test
legacy =
    describe "url parsing"
        [ test "root-redirect-1" <|
            \_ ->
                parse ""
                    |> Expect.equal (Just <| Route.Redirect <| Route.Home <| Route.defaultParams Route.liveVersion)
        , test "root-redirect-2" <|
            \_ ->
                parse "#"
                    |> Expect.equal (Just <| Route.Redirect <| Route.Home <| Route.defaultParams Route.liveVersion)
        , test "legacy-1" <|
            \_ ->
                parse "#/b/1&2&3&4&5"
                    |> Expect.equal (Just <| Route.Redirect <| Route.Home { version = Route.legacyVersion, hero = "helpfulAdventurer", build = Just "1&2&3&4&5", search = Nothing })
        , test "legacy-2" <|
            \_ ->
                parse "#/h/somehero"
                    |> Expect.equal (Just <| Route.Redirect <| Route.Home { version = Route.legacyVersion, hero = "somehero", build = Nothing, search = Nothing })
        , test "legacy-3" <|
            \_ ->
                parse "#/h/somehero/1&2&3"
                    |> Expect.equal (Just <| Route.Redirect <| Route.Home { version = Route.legacyVersion, hero = "somehero", build = Just "1&2&3", search = Nothing })
        , test "convenience-1" <|
            \_ ->
                parse "#/g/v123"
                    |> Expect.equal (Just <| Route.Redirect <| Route.Home { version = "v123", hero = "helpfulAdventurer", build = Nothing, search = Nothing })
        ]


loc : Url
loc =
    { protocol = Url.Https
    , host = ""
    , port_ = Nothing
    , path = ""
    , query = Nothing
    , fragment = Nothing
    }
