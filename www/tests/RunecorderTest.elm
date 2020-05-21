module RunecorderTest exposing (..)

import Dict exposing (Dict)
import Expect exposing (Expectation)
import GameData exposing (FatigueId(..), Spell)
import Model.Runecorder as R
import Route exposing (Route)
import Set exposing (Set)
import Test exposing (..)


mockIce1 : Spell
mockIce1 =
    { id = "ice1"
    , costMultiplier = 0.6
    , damageMultiplier = 1
    , description = ""
    , displayName = "ice-nine"
    , manaCost = 0
    , msecsPerRune = 1400
    , rank = 1
    , runeCombination = [ 2, 8 ]
    , spellPanelIcon = "idunnolol"
    , spellRings = [ "idunnolol" ]
    , tier = 1
    , types = Set.fromList [ 2 ]
    }


mockIce2 : Spell
mockIce2 =
    { mockIce1
        | id = "ice2"
        , runeCombination = [ 2, 2, 8 ]
        , rank = 2
        , tier = 2
    }


mockIce3 : Spell
mockIce3 =
    { mockIce1
        | id = "ice3"
        , runeCombination = [ 2, 2, 2, 8 ]
        , rank = 3
        , tier = 3
    }


mockEnergon : Spell
mockEnergon =
    { id = "energon cube"
    , costMultiplier = 0
    , damageMultiplier = 0
    , description = ""
    , displayName = "energon"
    , manaCost = 25
    , msecsPerRune = 1000
    , rank = 0
    , runeCombination = [ 7, 5, 2, 8 ]
    , spellPanelIcon = "idunnolol"
    , spellRings = [ "idunnolol" ]
    , tier = 0
    , types = Set.empty
    }


spells =
    Dict.fromList
        [ ( "ice1", mockIce1 )
        , ( "ice2", mockIce2 )
        , ( "ice3", mockIce3 )
        , ( "energon cube", mockEnergon )
        ]


all =
    describe "runecorder"
        [ describe "parse"
            [ test "parse empty" <|
                \_ ->
                    ""
                        |> R.parse spells
                        |> Expect.equal (Ok [])
            , test "parse nonempty" <|
                \_ ->
                    " ice1 ; energon cube; wait 2300; click; "
                        |> R.parse spells
                        |> Expect.equal (Ok [ R.SpellAction mockIce1, R.SpellAction mockEnergon, R.WaitAction 2300, R.ClickAction ])
            , test "parse error: wait" <|
                \_ ->
                    "ice1;wait twopointthree;"
                        |> R.parse spells
                        |> Expect.err
            , test "parse error: bogus spell" <|
                \_ ->
                    "ice9;"
                        |> R.parse spells
                        |> Expect.err
            , test "parse error: semicolon" <|
                \_ ->
                    "ice1"
                        |> R.parse spells
                        |> Expect.err
            ]
        , describe "run"
            [ test "run empty" <|
                \_ ->
                    ""
                        |> R.parse spells
                        |> Result.map R.run
                        |> Expect.equal
                            (Ok
                                { durationMillis = 0
                                , energy = 0
                                , mana = 0
                                , buffTimelines = Dict.empty
                                , fatigueTimelines = Dict.empty
                                }
                            )
            , test "run nonempty" <|
                \_ ->
                    " ice1 ; energon cube; wait 2600; click; wait 20000;"
                        |> R.parse spells
                        |> Result.map R.run
                        |> Expect.equal
                            (Ok
                                { durationMillis = 26000

                                -- energy = regen + energon - spells
                                , energy = 26 + (300 * 0.025 * 5) - 6
                                , mana = 26 * 1.25 - 25
                                , buffTimelines =
                                    Dict.fromList
                                        [ ( "buff:energon"
                                          , [ { buff = R.buffEnergon, updated = 3400, stacks = Just 1 }
                                            , { buff = R.buffEnergon, updated = 21400, stacks = Nothing }
                                            ]
                                          )
                                        ]
                                , fatigueTimelines =
                                    Dict.fromList
                                        [ ( "Ice"
                                          , [ { fatigue = GameData.fatigue Ice, updated = 1400, stacks = Just 1, energonStacks = 0 }
                                            , { fatigue = GameData.fatigue Ice, updated = 6400, stacks = Just 1, energonStacks = 1 }
                                            , { fatigue = GameData.fatigue Ice, updated = 9400, stacks = Just 1, energonStacks = 2 }
                                            , { fatigue = GameData.fatigue Ice, updated = 9400, stacks = Nothing, energonStacks = 0 }
                                            ]
                                          )
                                        ]
                                }
                            )
            , test "run buffs" <|
                \_ ->
                    let
                        dur =
                            1400 + 2000 + 15000 + 2000 + 15000 + 2000 + 17000 + 2000
                    in
                    " ice1 ; energon cube; wait 15000; energon cube; wait 15000; energon cube; wait 17000; energon cube;"
                        |> R.parse spells
                        |> Result.map R.run
                        |> Expect.equal
                            (Ok
                                { durationMillis = dur

                                -- this energy looks reasonable, and I don't want to calculate all those energons by hand
                                , energy = 162.9
                                , mana = toFloat dur / 1000 * 1.25 - 4 * 25
                                , buffTimelines =
                                    Dict.fromList
                                        [ ( "buff:energon"
                                            -- 3 energon casts, just close enough together to stack
                                          , [ { buff = R.buffEnergon, updated = 3400, stacks = Just 1 }
                                            , { buff = R.buffEnergon, updated = 20400, stacks = Just 2 }
                                            , { buff = R.buffEnergon, updated = 37400, stacks = Just 3 }

                                            -- oh no, we were too slow and it expired while casting stack 4
                                            , { buff = R.buffEnergon, updated = 55400, stacks = Nothing }
                                            , { buff = R.buffEnergon, updated = 56400, stacks = Just 1 }

                                            -- we don't simulate beyond action durations, `simulation.durationMillis`
                                            -- , { buff = R.buffEnergon, updated = 74400, stacks = Nothing }
                                            ]
                                          )
                                        ]
                                , fatigueTimelines =
                                    Dict.fromList
                                        [ ( "Ice"
                                          , [ { fatigue = GameData.fatigue Ice, updated = 1400, stacks = Just 1, energonStacks = 0 }
                                            , { fatigue = GameData.fatigue Ice, updated = 6400, stacks = Just 1, energonStacks = 1 }
                                            , { fatigue = GameData.fatigue Ice, updated = 9400, stacks = Just 1, energonStacks = 2 }
                                            , { fatigue = GameData.fatigue Ice, updated = 9400, stacks = Nothing, energonStacks = 0 }
                                            ]
                                          )
                                        ]
                                }
                            )
            , test "run fatigue, no energon" <|
                \_ ->
                    let
                        dur =
                            2800 + 2100 + 40000
                    in
                    " ice3 ; ice2 ; wait 40000;"
                        |> R.parse spells
                        |> Result.map R.run
                        |> Expect.equal
                            (Ok
                                { durationMillis = dur

                                -- energy = regen - ice3 - ice2*(3 fatigue)
                                , energy = dur / 1000 - 12 - (9 * (1 + 0.04 * 3))
                                , mana = dur / 1000 * 1.25 - 0
                                , buffTimelines = Dict.empty
                                , fatigueTimelines =
                                    Dict.fromList
                                        [ ( "Ice"
                                          , [ { fatigue = GameData.fatigue Ice, updated = 2800, stacks = Just 3, energonStacks = 0 }
                                            , { fatigue = GameData.fatigue Ice, updated = 4900, stacks = Just 5, energonStacks = 0 }

                                            -- expiration times are tricky! 8 seconds from the *first* cast.
                                            -- second cast changes stack count, but not expiration timestamp
                                            , { fatigue = GameData.fatigue Ice, updated = 10800, stacks = Just 4, energonStacks = 0 }
                                            , { fatigue = GameData.fatigue Ice, updated = 18800, stacks = Just 3, energonStacks = 0 }
                                            , { fatigue = GameData.fatigue Ice, updated = 26800, stacks = Just 2, energonStacks = 0 }
                                            , { fatigue = GameData.fatigue Ice, updated = 34800, stacks = Just 1, energonStacks = 0 }
                                            , { fatigue = GameData.fatigue Ice, updated = 42800, stacks = Nothing, energonStacks = 0 }
                                            ]
                                          )
                                        ]
                                }
                            )
            ]
        ]
