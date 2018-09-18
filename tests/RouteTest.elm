module RouteTest exposing (flagParser, loc, suite)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Route
import Test exposing (..)
import Url as Url exposing (Url)
import Url.Parser as P exposing ((<?>))


flagParser : Bool -> Url -> Maybe Bool
flagParser default =
    P.parse <| P.top <?> Route.flagParam "enableTest" default


suite : Test
suite =
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


loc : Url
loc =
    { protocol = Url.Https
    , host = ""
    , port_ = Nothing
    , path = ""
    , query = Nothing
    , fragment = Nothing
    }
