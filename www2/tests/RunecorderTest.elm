module RunecorderTest exposing (..)

import Dict exposing (Dict)
import Expect exposing (Expectation)
import GameData exposing (FatigueId(..), Spell)
import List.Extra
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


mapUniqTimeline : (R.SimSnapshot -> s) -> R.SimTimeline -> List ( R.Timestamp, s )
mapUniqTimeline fn sim =
    -- map: (Event, SimSnapshot) -> (Timestamp, s)
    sim.timeline
        |> List.map (Tuple.mapFirst .at)
        |> (::) ( 0, sim.start )
        |> List.map (Tuple.mapSecond fn)
        -- uniq
        |> List.Extra.groupWhile (\a b -> Tuple.second a == Tuple.second b)
        |> List.map Tuple.first


buffStacksTimeline : R.SimTimeline -> List ( R.Timestamp, Dict String Int )
buffStacksTimeline =
    mapUniqTimeline (.buffs >> Dict.map (always .stacks))


fatigueStacksTimeline : R.SimTimeline -> List ( R.Timestamp, Dict String ( Int, Int ) )
fatigueStacksTimeline =
    mapUniqTimeline (.fatigue >> Dict.map (always (\f -> ( f.stacks, f.energonStacks ))))


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
                        |> Expect.equal
                            (Ok
                                [ R.SpellAction mockIce1
                                , R.SpellAction mockEnergon
                                , R.WaitAction 2300
                                , R.ClickAction
                                ]
                            )
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
                            (Ok { start = R.emptySim, end = R.emptySim, timeline = [] })
            , test "run nonempty" <|
                \_ ->
                    " ice1 ; energon cube; ice1; wait 1200; click; wait 20000;"
                        |> R.parse spells
                        |> Result.map R.run
                        |> Expect.all
                            [ Result.map .end
                                >> Expect.equal
                                    (Ok
                                        { now = 27000

                                        -- energy: regen + energon - spent
                                        , energySpent = 12.24
                                        , energyEnergonTicks = 6
                                        , energy = 27 + (300 * 0.025 * 6) - 12.24
                                        , manaSpent = 25
                                        , mana = 27 * 1.25 - 25
                                        , buffs = Dict.empty
                                        , fatigue = Dict.empty
                                        }
                                    )
                            , Result.map buffStacksTimeline
                                >> Expect.equal
                                    (Ok
                                        [ ( 0, Dict.empty )
                                        , ( 4400, Dict.fromList [ ( "buff:energon", 1 ) ] )
                                        , ( 22400, Dict.empty )
                                        ]
                                    )
                            , Result.map fatigueStacksTimeline
                                >> Expect.equal
                                    (Ok
                                        [ ( 0, Dict.empty )
                                        , ( 1400, Dict.fromList [ ( "Ice", ( 1, 0 ) ) ] )
                                        , ( 5800, Dict.fromList [ ( "Ice", ( 2, 0 ) ) ] )
                                        , ( 7400, Dict.fromList [ ( "Ice", ( 2, 1 ) ) ] )

                                        -- fatigue tick
                                        , ( 9400, Dict.fromList [ ( "Ice", ( 1, 1 ) ) ] )

                                        -- energon ticks
                                        , ( 10400, Dict.fromList [ ( "Ice", ( 1, 2 ) ) ] )
                                        , ( 13400, Dict.fromList [ ( "Ice", ( 1, 3 ) ) ] )
                                        , ( 16400, Dict.fromList [ ( "Ice", ( 1, 4 ) ) ] )

                                        -- fatigue tick
                                        , ( 17400, Dict.empty )
                                        ]
                                    )
                            ]
            , test "run buffs" <|
                \_ ->
                    let
                        dur =
                            1400 + 3000 + 14000 + 3000 + 14000 + 3000 + 16000 + 3000
                    in
                    " ice1 ; energon cube; wait 14000; energon cube; wait 14000; energon cube; wait 16000; energon cube;"
                        |> R.parse spells
                        |> Result.map R.run
                        |> Expect.all
                            [ Result.map .end
                                >> Expect.equal
                                    (Ok
                                        { now = dur
                                        , energySpent = 6
                                        , energyEnergonTicks = 33
                                        , energy = 298.9
                                        , manaSpent = 4 * 25
                                        , mana = toFloat dur / 1000 * 1.25 - 4 * 25
                                        , buffs = Dict.fromList [ ( "buff:energon", { buff = R.buffEnergon, stacks = 1, updated = 57400 } ) ]
                                        , fatigue = Dict.empty
                                        }
                                    )
                            , Result.map buffStacksTimeline
                                >> Expect.equal
                                    (Ok
                                        [ ( 0, Dict.empty )

                                        -- 3 energon casts, just close enough together to stack
                                        , ( 4400, Dict.fromList [ ( "buff:energon", 1 ) ] )
                                        , ( 21400, Dict.fromList [ ( "buff:energon", 2 ) ] )
                                        , ( 38400, Dict.fromList [ ( "buff:energon", 3 ) ] )

                                        -- oh no, we were too slow and it expired while casting stack 4
                                        , ( 56400, Dict.empty )
                                        , ( 57400, Dict.fromList [ ( "buff:energon", 1 ) ] )

                                        -- we don't simulate beyond action durations, `simulation.durationMillis`
                                        -- , { buff = R.buffEnergon, updated = 74400, stacks = Nothing }
                                        ]
                                    )
                            ]
            , test "run fatigue, no energon" <|
                \_ ->
                    let
                        dur =
                            4200 + 2800 + 40000
                    in
                    " ice3 ; ice2 ; wait 40000;"
                        |> R.parse spells
                        |> Result.map R.run
                        |> Expect.all
                            [ Result.map .end
                                >> Expect.equal
                                    (Ok
                                        { now = dur
                                        , energySpent = 12 + (9 * (1 + 0.04 * 3))
                                        , energyEnergonTicks = 0
                                        , energy = dur / 1000 - 12 - (9 * (1 + 0.04 * 3))
                                        , manaSpent = 0
                                        , mana = toFloat dur / 1000 * 1.25
                                        , buffs = Dict.empty
                                        , fatigue = Dict.empty
                                        }
                                    )
                            , Result.map buffStacksTimeline
                                >> Expect.equal (Ok [ ( 0, Dict.empty ) ])
                            , Result.map fatigueStacksTimeline
                                >> Expect.equal
                                    (Ok
                                        [ ( 0, Dict.empty )
                                        , ( 4200, Dict.fromList [ ( "Ice", ( 3, 0 ) ) ] )
                                        , ( 7000, Dict.fromList [ ( "Ice", ( 5, 0 ) ) ] )

                                        -- expiration times are tricky! 8 seconds from the *first* cast.
                                        -- second cast changes stack count, but not expiration timestamp
                                        , ( 12200, Dict.fromList [ ( "Ice", ( 4, 0 ) ) ] )
                                        , ( 20200, Dict.fromList [ ( "Ice", ( 3, 0 ) ) ] )
                                        , ( 28200, Dict.fromList [ ( "Ice", ( 2, 0 ) ) ] )
                                        , ( 36200, Dict.fromList [ ( "Ice", ( 1, 0 ) ) ] )
                                        , ( 44200, Dict.empty )
                                        ]
                                    )
                            ]
            ]
        ]
