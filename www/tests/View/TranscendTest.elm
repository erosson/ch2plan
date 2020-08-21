module View.TranscendTest exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import GameData.Stats as Stats
import Test exposing (..)
import Url as Url exposing (Url)
import Url.Parser as P exposing ((<?>))
import View.Transcend as Transcend


suite : Test
suite =
    describe "costFunction values"
        [ test "cid linear values" <|
            \_ ->
                [ 0, 1, 2, 3, 4, 5, 6, 7 ]
                    |> List.filterMap (Transcend.nextLevelCost { trait = Nothing, costFunction = ( Stats.LinearExponential, [ 5, 1, 1.1 ] ) })
                    |> Expect.equal [ 5, 7, 9, 11, 14, 17, 20, 24 ]
        , test "cid nonlinear values" <|
            \_ ->
                [ 0, 1, 2, 3 ]
                    |> List.filterMap (Transcend.nextLevelCost { trait = Nothing, costFunction = ( Stats.LinearExponential, [ 5, 2, 2 ] ) })
                    |> Expect.equal [ 5, 14, 36, 88 ]
        , test "cid improved ascension" <|
            \_ ->
                [ 0, 1, 2, 3 ]
                    |> List.filterMap (Transcend.nextLevelCost { trait = Nothing, costFunction = ( Stats.ExponentialMultiplier, [ 5 ] ) })
                    |> Expect.equal [ 1, 5, 25, 125 ]
        ]
