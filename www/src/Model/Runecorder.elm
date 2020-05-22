module Model.Runecorder exposing
    ( Action(..)
    , Duration
    , Event(..)
    , Simulation
    , SpellAction
    , Timestamp
    , buffDarkRitual
    , buffEnergon
    , deadEndToSourceLine
    , deadEndToString
    , deadEndsToString
    , duration
    , fatigueStacks
    , ignoreParseErrors
    , parse
    , run
    , unrollStatements
    )

import Dict exposing (Dict)
import Dict.Extra
import GameData exposing (Fatigue, Spell)
import List.Extra
import Maybe.Extra
import Parser as P exposing ((|.), (|=), Parser)
import Scheduler exposing (Scheduler)
import Set exposing (Set)



-- re-exports


type alias Timestamp =
    Scheduler.Timestamp


type alias Duration =
    Scheduler.Duration



-- Action parsing


type Action s
    = WaitAction Int
    | ClickAction
    | SpellAction s


type Statement s
    = ActionStatement (Result String (Action s))
    | LoopStatement Int (List (Statement s))


type alias SpellAction =
    Action Spell


type alias ParseError =
    { error : String, line : String }


parse : Dict String s -> String -> Result (List P.DeadEnd) (List (Statement s))
parse spells source =
    source
        |> P.run (parser spells)
        -- |> Result.mapError Debug.toString
        -- |> Result.mapError P.deadEndsToString
        |> identity


deadEndToSourceLine : String -> P.DeadEnd -> String
deadEndToSourceLine src deadEnd =
    String.lines src
        |> List.drop (deadEnd.row - 1)
        |> List.head
        |> Maybe.withDefault ""


deadEndsToString : List P.DeadEnd -> String
deadEndsToString deadEnds =
    -- stolen from https://github.com/elm/parser/pull/38
    List.foldl (++) "" (List.map deadEndToString deadEnds)


deadEndToString : P.DeadEnd -> String
deadEndToString deadEnd =
    -- stolen from https://github.com/elm/parser/pull/38
    let
        position : String
        position =
            "row:" ++ String.fromInt deadEnd.row ++ " col:" ++ String.fromInt deadEnd.col ++ "\n"
    in
    case deadEnd.problem of
        P.Expecting str ->
            "Expecting " ++ str ++ "at " ++ position

        P.ExpectingInt ->
            "ExpectingInt at " ++ position

        P.ExpectingHex ->
            "ExpectingHex at " ++ position

        P.ExpectingOctal ->
            "ExpectingOctal at " ++ position

        P.ExpectingBinary ->
            "ExpectingBinary at " ++ position

        P.ExpectingFloat ->
            "ExpectingFloat at " ++ position

        P.ExpectingNumber ->
            "ExpectingNumber at " ++ position

        P.ExpectingVariable ->
            "ExpectingVariable at " ++ position

        P.ExpectingSymbol str ->
            "ExpectingSymbol " ++ str ++ " at " ++ position

        P.ExpectingKeyword str ->
            "ExpectingKeyword " ++ str ++ "at " ++ position

        P.ExpectingEnd ->
            "ExpectingEnd at " ++ position

        P.UnexpectedChar ->
            "UnexpectedChar at " ++ position

        P.Problem str ->
            str ++ " at " ++ position

        P.BadRepeat ->
            "BadRepeat at " ++ position


unrollStatements : List (Statement s) -> List (Result String (Action s))
unrollStatements =
    List.concatMap
        (\statement ->
            case statement of
                ActionStatement act ->
                    [ act ]

                LoopStatement n sts ->
                    List.range 1 n
                        |> List.concatMap (always sts)
                        |> unrollStatements
        )


ignoreParseErrors : Result e (List (Result String (Action s))) -> List (Action s)
ignoreParseErrors =
    Result.withDefault [] >> List.filterMap Result.toMaybe


parser : Dict String s -> Parser (List (Statement s))
parser spells =
    P.succeed identity
        |. spaces
        |= statementsParser spells
        |. spaces
        |. P.end


statementsParser : Dict String s -> Parser (List (Statement s))
statementsParser spells =
    let
        loop : List (Statement s) -> Parser (P.Step (List (Statement s)) (List (Statement s)))
        loop stmts =
            P.oneOf
                [ P.succeed (\s -> P.Loop (s :: stmts))
                    |= statementParser spells
                    |. spaces
                , P.succeed ()
                    |> P.map (\_ -> P.Done <| List.reverse stmts)
                ]
    in
    P.loop [] loop


reserved : Set String
reserved =
    Set.fromList [ "wait", "click", "loop" ]


statementParser : Dict String s -> Parser (Statement s)
statementParser spells =
    P.succeed identity
        |= P.oneOf
            [ P.succeed LoopStatement
                |. P.keyword "loop"
                |. spaces
                |= (P.int
                        |> P.andThen
                            (\n ->
                                if n <= 0 then
                                    P.problem "loop minimum: 1"

                                else if n > 20 then
                                    P.problem "loop maximum: 20"

                                else
                                    P.succeed n
                            )
                   )
                |. spaces
                |. P.symbol "{"
                |. spaces
                |= statementsParser spells
                |. spaces
                |. P.symbol "}"
            , actionParser spells
                |> P.map ActionStatement
            ]
        |. spaces
        |. P.symbol ";"


actionParser : Dict String a -> Parser (Result String (Action a))
actionParser spells =
    P.oneOf
        [ P.succeed (Ok << WaitAction)
            |. P.keyword "wait"
            |. spaces
            |= P.int
        , P.succeed (Ok ClickAction)
            |. P.keyword "click"
        , P.succeed identity
            |= P.variable { start = Char.isAlpha, inner = \c -> Char.isAlpha c || Char.isDigit c || c == ' ', reserved = reserved }
            |> P.andThen
                (\name ->
                    case Dict.get (name |> String.toLower |> String.trim) spells of
                        Nothing ->
                            -- P.succeed <| Err <| "no such spell: " ++ name
                            P.problem <| "no such spell: " ++ name

                        Just a ->
                            P.succeed <| Ok <| SpellAction a
                )
        ]


spaces : Parser ()
spaces =
    P.loop 0 <|
        ifProgress <|
            P.oneOf
                -- [ P.lineComment "//"
                -- lineComment breaks error messages, https://github.com/elm/parser/issues/46
                [ P.succeed () |. P.symbol "//" |. P.chompWhile (\c -> c /= '\n')
                , P.multiComment "/*" "*/" P.Nestable

                --, P.spaces
                -- no soft-tabs in the browser, so we should accept hard tabs
                , P.chompWhile (\c -> c == ' ' || c == '\n' || c == '\u{000D}' || c == '\t')
                ]


ifProgress : Parser a -> Int -> Parser (P.Step Int ())
ifProgress parser_ offset =
    P.succeed identity
        |. parser_
        |= P.getOffset
        |> P.map
            (\newOffset ->
                if offset == newOffset then
                    P.Done ()

                else
                    P.Loop newOffset
            )



-- Buffs


type alias Buff =
    { id : String
    , spell : String
    , duration : Duration
    , ticksMillis : List Duration
    , maxStacks : Maybe Int
    }


buffEnergon =
    Buff "buff:energon" "energon cube" 18000 [ 3000, 6000, 9000, 12000, 15000 ] Nothing


buffDarkRitual =
    Buff "buff:dark-ritual" "iceFireDarkRitual" 60000 [] (Just 20)


bufflist : List Buff
bufflist =
    [ buffEnergon, buffDarkRitual ]


buffsById : Dict String Buff
buffsById =
    Dict.Extra.fromListBy (.id >> String.toLower) bufflist


buffsBySpell : Dict String Buff
buffsBySpell =
    Dict.Extra.fromListBy (.spell >> String.toLower) bufflist



-- Simulation


type alias Simulation =
    { duration : Duration
    , energy : Float
    , mana : Float
    , buffTimelines : Dict String (List BuffSnapshot)
    , fatigueTimelines : Dict String (List FatigueSnapshot)
    , log : List ( Timestamp, Event )
    }


type alias BuffSnapshot =
    { buff : Buff
    , updated : Timestamp
    , stacks : Maybe Int
    }


type alias FatigueSnapshot =
    { fatigue : Fatigue
    , updated : Timestamp
    , stacks : Maybe Int

    -- 1 energon stack has a 20% chance to remove one fatigue stack.
    -- Random simulations are hard, so instead, we treat energon stacks as fractional stacks.
    -- Floating point imprecision is crappy, so instead, we count normal stacks and energon stacks as separate numbers.
    -- For an estimate of true stacks, see `fatigueStacks`
    , energonStacks : Int
    }


energyRegen =
    1


manaRegen =
    1.25


energyMax =
    300


manaMax =
    300


energyCostPerFatigueStack =
    0.04


type Event
    = ActionCompleted SpellAction
    | BuffExpires Buff
    | BuffTicks Buff
    | FatigueExpires Fatigue


run : List SpellAction -> Simulation
run acts =
    let
        dur =
            acts |> List.map actionDuration |> List.sum

        foldScheduler : SpellAction -> ( Duration, Scheduler Event ) -> ( Duration, Scheduler Event )
        foldScheduler act ( now0, sched ) =
            let
                now =
                    now0 + actionDuration act
            in
            ( now, Scheduler.setTimeout now (ActionCompleted act) sched )

        scheduler0 : Scheduler Event
        scheduler0 =
            List.foldl foldScheduler ( 0, Scheduler.empty 0 ) acts |> Tuple.second

        sim0 : Simulation
        sim0 =
            -- simple; easy to compute without simulation
            { duration = dur
            , mana = manaRegen * (toFloat dur / 1000) - (acts |> List.map (manaCost >> toFloat) |> List.sum)

            -- complex; simulation required
            , energy = energyRegen * (toFloat dur / 1000)
            , buffTimelines = Dict.empty
            , fatigueTimelines = Dict.empty
            , log = []
            }

        sim : Simulation
        sim =
            Scheduler.runUntil dur simStep ( sim0, scheduler0 )
                |> Tuple.first
    in
    { sim
      -- timelines are constructed newest :: oldest (because linked lists), but we want to display oldest :: newest
        | buffTimelines = sim.buffTimelines |> Dict.map (always List.reverse)
        , fatigueTimelines = sim.fatigueTimelines |> Dict.map (always List.reverse)
        , log = sim.log |> List.reverse
    }


simStep : Timestamp -> Event -> ( Simulation, Scheduler Event ) -> ( Simulation, Scheduler Event )
simStep time event ( sim, sched ) =
    Tuple.mapFirst (\sim_ -> { sim_ | log = ( time, event ) :: sim_.log }) <|
        case event of
            ActionCompleted (SpellAction spell) ->
                ( sim |> paySpellEnergy spell, sched )
                    |> refreshSpellBuff time spell
                    |> applySpellFatigue time spell

            ActionCompleted _ ->
                -- TODO click energy, lightning free-click buffs
                ( sim, sched )

            BuffExpires buff ->
                ( { sim
                    | buffTimelines =
                        sim.buffTimelines
                            |> Dict.update buff.id (Maybe.map ((::) { buff = buff, updated = time, stacks = Nothing }))
                  }
                    |> applyBuffTick time buff
                , sched
                )

            BuffTicks buff ->
                ( sim |> applyBuffTick time buff
                , sched
                )

            FatigueExpires fat ->
                let
                    sim1 =
                        { sim
                            | fatigueTimelines =
                                sim.fatigueTimelines
                                    |> Dict.update fat.label (Maybe.withDefault [] >> expireFatigue time fat >> Just)
                        }
                in
                ( sim1
                , case Dict.get fat.label sim1.fatigueTimelines |> Maybe.andThen List.head |> Maybe.andThen .stacks of
                    Nothing ->
                        sched

                    Just _ ->
                        -- there are still fatigue stacks left - schedule another expiration
                        sched |> Scheduler.setTimeout 8000 (FatigueExpires fat)
                )


paySpellEnergy : Spell -> Simulation -> Simulation
paySpellEnergy spell sim =
    let
        stacks : Float
        stacks =
            GameData.spellFatigue spell
                |> List.map Tuple.first
                |> List.filterMap (\fat -> Dict.get fat.label sim.fatigueTimelines)
                |> List.filterMap List.head
                |> List.filterMap fatigueStacks
                |> List.sum

        baseCost : Int
        baseCost =
            toFloat (List.length spell.runeCombination) * spell.costMultiplier * 5 |> round

        cost : Float
        cost =
            (1 + stacks * energyCostPerFatigueStack) * toFloat baseCost
    in
    { sim | energy = sim.energy - cost }


applyBuffTick : Timestamp -> Buff -> Simulation -> Simulation
applyBuffTick time buff sim =
    case buff.id of
        "buff:energon" ->
            case Dict.get buff.id sim.buffTimelines |> Maybe.andThen List.head |> Maybe.andThen .stacks of
                Nothing ->
                    sim

                Just stacks ->
                    { sim
                        | fatigueTimelines =
                            sim.fatigueTimelines
                                |> Dict.map (\_ -> addFatigueEnergonStack time stacks)
                        , energy = sim.energy + 0.025 * energyMax * toFloat stacks
                    }

        _ ->
            sim


expireFatigue : Timestamp -> Fatigue -> List FatigueSnapshot -> List FatigueSnapshot
expireFatigue time fat timeline =
    case List.head timeline of
        Nothing ->
            { fatigue = fat, updated = time, stacks = Nothing, energonStacks = 0 } :: timeline

        Just snapshot ->
            let
                stacks =
                    -- subtract one stack, and assign Nothing if out of stacks
                    snapshot.stacks
                        |> Maybe.map (\s -> s - 1)
                        |> Maybe.Extra.filter (\s -> s > 0)
            in
            { snapshot
                | updated = time
                , stacks = stacks
                , energonStacks =
                    if stacks == Nothing then
                        0

                    else
                        snapshot.energonStacks
            }
                :: timeline


applySpellFatigue : Timestamp -> Spell -> ( Simulation, Scheduler Event ) -> ( Simulation, Scheduler Event )
applySpellFatigue time spell state0 =
    let
        applyFatigue : ( Fatigue, Int ) -> ( Simulation, Scheduler Event ) -> ( Simulation, Scheduler Event )
        applyFatigue ( fat, stacks ) ( sim, sched ) =
            -- add fatigue stacks
            ( { sim
                | fatigueTimelines =
                    sim.fatigueTimelines
                        |> Dict.update fat.label (Maybe.withDefault [] >> addFatigueStack time fat stacks >> Just)
              }
              -- add fatigue expiration, if it's not already there
            , if Scheduler.any (\e -> e.payload == FatigueExpires fat) sched then
                sched

              else
                sched |> Scheduler.setTimeout 8000 (FatigueExpires fat)
            )
    in
    GameData.spellFatigue spell
        |> List.foldl applyFatigue state0


addFatigueStack : Timestamp -> Fatigue -> Int -> List FatigueSnapshot -> List FatigueSnapshot
addFatigueStack time {- $$$ -} fat stacks {- $$$ -} timeline =
    case timeline of
        [] ->
            [ { updated = time, fatigue = fat, stacks = Just stacks, energonStacks = 0 } ]

        snapshot :: tail ->
            { snapshot
                | updated = time
                , stacks = Just <| stacks + Maybe.withDefault 0 snapshot.stacks
            }
                :: timeline


addFatigueEnergonStack : Timestamp -> Int -> List FatigueSnapshot -> List FatigueSnapshot
addFatigueEnergonStack time enstacks timeline =
    case timeline of
        [] ->
            []

        snapshot0 :: tail ->
            let
                snapshot =
                    { snapshot0
                        | updated = time
                        , energonStacks = snapshot0.energonStacks + enstacks
                    }
                        |> normalizeEnergonStacks
            in
            if snapshot.stacks == snapshot0.stacks && snapshot.energonStacks == snapshot0.energonStacks then
                timeline

            else
                snapshot :: timeline


normalizeEnergonStacks : FatigueSnapshot -> FatigueSnapshot
normalizeEnergonStacks snapshot =
    case snapshot.stacks of
        Nothing ->
            { snapshot | energonStacks = 0 }

        Just stacks0 ->
            let
                stacks =
                    stacks0 - snapshot.energonStacks // 5
            in
            if stacks <= 0 then
                { snapshot | stacks = Nothing, energonStacks = 0 }

            else
                { snapshot | stacks = Just stacks, energonStacks = snapshot.energonStacks |> modBy 5 }


refreshSpellBuff : Timestamp -> Spell -> ( Simulation, Scheduler Event ) -> ( Simulation, Scheduler Event )
refreshSpellBuff time spell ( sim, sched ) =
    case Dict.get (String.toLower spell.id) buffsBySpell of
        Just buff ->
            -- add a buff stack
            ( { sim
                | buffTimelines =
                    sim.buffTimelines
                        |> Dict.update buff.id (Maybe.withDefault [] >> addBuffStack time buff >> Just)
              }
              -- delay buff expiration/ticks
            , sched
                |> removeBuffEvents buff.id
                |> Scheduler.setTimeout buff.duration (BuffExpires buff)
                |> (\s -> List.foldl (\d -> Scheduler.setTimeout d (BuffTicks buff)) s buff.ticksMillis)
            )

        Nothing ->
            ( sim, sched )


addBuffStack : Timestamp -> Buff -> List BuffSnapshot -> List BuffSnapshot
addBuffStack time buff timeline =
    case timeline of
        [] ->
            [ { updated = time, buff = buff, stacks = Just 1 } ]

        snapshot :: tail ->
            { snapshot
                | updated = time
                , stacks = Just <| 1 + Maybe.withDefault 0 snapshot.stacks
            }
                :: timeline


removeBuffEvents : String -> Scheduler Event -> Scheduler Event
removeBuffEvents buffId =
    Scheduler.filter
        (\event ->
            case event.payload of
                BuffExpires expires ->
                    buffId /= expires.id

                BuffTicks expires ->
                    buffId /= expires.id

                _ ->
                    True
        )


manaCost : SpellAction -> Int
manaCost act =
    case act of
        SpellAction s ->
            s.manaCost

        _ ->
            0


actionDuration : SpellAction -> Duration
actionDuration act =
    case act of
        WaitAction millis ->
            millis

        ClickAction ->
            0

        SpellAction s ->
            duration s


duration : Spell -> Duration
duration s =
    (List.length s.runeCombination - 1) * s.msecsPerRune


fatigueStacks : FatigueSnapshot -> Maybe Float
fatigueStacks s =
    s.stacks |> Maybe.map (\stacks -> toFloat stacks - toFloat s.energonStacks / 5)
