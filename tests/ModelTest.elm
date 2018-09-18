module ModelTest exposing (flags, loc, suite)

import Dict as Dict exposing (Dict)
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Json.Encode as E
import Maybe.Extra
import Model
import Route
import Test exposing (..)
import Url as Url exposing (Url)


suite : Test
suite =
    describe "init"
        [ test "sets search" <|
            \_ ->
                Expect.equal (Just "foo")
                    ({ loc | fragment = Just "/g/vTest/helpfulAdventurer?q=foo" }
                        |> Route.parse
                        |> Route.params
                        |> Maybe.Extra.unwrap Nothing .search
                    )
        , test "no search" <|
            \_ ->
                Expect.equal Nothing
                    ({ loc | fragment = Just "/g/vTest/helpfulAdventurer" }
                        |> Route.parse
                        |> Route.params
                        |> Maybe.Extra.unwrap Nothing .search
                    )
        , test "invalid search" <|
            \_ ->
                Expect.equal (Just "(")
                    ({ loc | fragment = Just "/g/vTest/helpfulAdventurer?q=(" }
                        |> Route.parse
                        |> Route.params
                        |> Maybe.Extra.unwrap Nothing .search
                    )
        ]


flags : Model.Flags
flags =
    -- bare minimum required for a non-error model
    { changelog = ""
    , gameData =
        E.object
            [ ( "versionList", [ "vTest" ] |> E.list E.string )
            , ( "byVersion"
              , E.object
                    [ ( "vTest"
                      , E.object
                            [ ( "versionSlug", "vTest" |> E.string )
                            , ( "heroes", E.object [] )
                            , ( "stats"
                              , E.object
                                    [ ( "statValueFunctions", E.object [] )
                                    , ( "characters", E.object [] )
                                    ]
                              )
                            ]
                      )
                    ]
              )
            ]
    , windowSize = { width = 1000, height = 1000 }
    }


loc : Url
loc =
    { protocol = Url.Https
    , host = ""
    , port_ = Nothing
    , path = ""
    , query = Nothing
    , fragment = Nothing
    }
