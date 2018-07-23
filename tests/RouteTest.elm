module RouteTest exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import UrlParser as P exposing ((<?>))
import Navigation
import Route


flagParser : Bool -> Navigation.Location -> Maybe Bool
flagParser default =
    P.parseHash <| P.top <?> Route.flagParam "enableTest" default


suite : Test
suite =
    describe "flagParam"
        [ test "default false, flag false" <| \_ -> Expect.equal (Just False) <| flagParser False { loc | search = "?enableTest=0" }
        , test "default false, flag true" <| \_ -> Expect.equal (Just True) <| flagParser False { loc | search = "?enableTest=1" }
        , test "default false, flag missing" <| \_ -> Expect.equal (Just False) <| flagParser False { loc | search = "" }
        , test "default false, flag value-empty" <| \_ -> Expect.equal (Just False) <| flagParser False { loc | search = "?enableTest=" }
        , test "default false, flag value-missing" <| \_ -> Expect.equal (Just False) <| flagParser False { loc | search = "?enableTest" }
        , test "default true, flag false" <| \_ -> Expect.equal (Just False) <| flagParser True { loc | search = "?enableTest=0" } -- this is the tricky one!
        , test "default true, flag true" <| \_ -> Expect.equal (Just True) <| flagParser True { loc | search = "?enableTest=1" }
        , test "default true, flag missing" <| \_ -> Expect.equal (Just True) <| flagParser True { loc | search = "" }
        ]


loc : Navigation.Location
loc =
    { href = ""
    , host = ""
    , hostname = ""
    , protocol = ""
    , origin = ""
    , port_ = ""
    , pathname = ""
    , search = ""
    , hash = ""
    , username = ""
    , password = ""
    }
