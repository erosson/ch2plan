module ModelTest exposing (..)

import Dict as Dict exposing (Dict)
import Json.Encode as E
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Navigation
import Model


suite : Test
suite =
    describe "init"
        [ test "sets search" <|
            \_ ->
                Expect.equal (Just "foo")
                    ({ loc | hash = "/g/vTest/helpfulAdventurer?q=foo" }
                        |> Model.init flags
                        |> Tuple.first
                        |> .searchString
                    )
        , test "no search" <|
            \_ ->
                Expect.equal Nothing
                    ({ loc | hash = "/g/vTest/helpfulAdventurer" }
                        |> Model.init flags
                        |> Tuple.first
                        |> .searchString
                    )
        , test "invalid search" <|
            \_ ->
                Expect.equal (Just "(")
                    ({ loc | hash = "/g/vTest/helpfulAdventurer?q=(" }
                        |> Model.init flags
                        |> Tuple.first
                        |> .searchString
                    )
        ]


flags : Model.Flags
flags =
    -- bare minimum required for a non-error model
    { changelog = ""
    , gameData =
        E.object
            [ ( "versionList", [ "vTest" ] |> List.map E.string |> E.list )
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
