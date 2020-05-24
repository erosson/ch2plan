module Model.Runecorder exposing
    ( Action(..)
    , DeadEnd
    , Duration
    , Event(..)
    , SimSnapshot
    , SimTimeline
    , SpellAction
    , Statement(..)
    , Timestamp
    , buffDarkRitual
    , buffEnergon
    , deadEndToSourceLine
    , deadEndToString
    , deadEndsToString
    , duration
    , emptySim
    , fatigueStacks
    , parse
    , parseStatements
    , run
    , unrollStatements
    )

import Dict exposing (Dict)
import Dict.Extra
import GameData exposing (Fatigue, Spell)
import List.Extra
import List.Nonempty as Nonempty exposing (Nonempty)
import Maybe.Extra
import Parser as P exposing ((|.), (|=), Parser)
import Scheduler exposing (Scheduler)
import Set exposing (Set)



-- re-exports


type alias Timestamp =
    Scheduler.Timestamp


type alias Duration =
    Scheduler.Duration


type alias DeadEnd =
    P.DeadEnd



-- Action parsing


type Action s
    = WaitAction Int
    | ClickAction
    | SpellAction s


type Statement s
    = ActionStatement (Action s)
    | LoopStatement Int (List (Statement s))


type alias SpellAction =
    Action Spell


type alias ParseError =
    { error : String, line : String }


parse : Dict String s -> String -> Result (List DeadEnd) (List (Action s))
parse spells =
    parseStatements spells >> Result.map unrollStatements


parseStatements : Dict String s -> String -> Result (List DeadEnd) (List (Statement s))
parseStatements spells source =
    source
        |> P.run (parser spells)
        -- |> Result.mapError Debug.toString
        -- |> Result.mapError P.deadEndsToString
        |> identity


deadEndToSourceLine : String -> DeadEnd -> String
deadEndToSourceLine src deadEnd =
    String.lines src
        |> List.drop (deadEnd.row - 1)
        |> List.head
        |> Maybe.withDefault ""


deadEndsToString : List DeadEnd -> String
deadEndsToString deadEnds =
    -- stolen from https://github.com/elm/parser/pull/38
    List.foldl (++) "" (List.map deadEndToString deadEnds)


deadEndToString : DeadEnd -> String
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


unrollStatements : List (Statement s) -> List (Action s)
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


actionParser : Dict String a -> Parser (Action a)
actionParser spells =
    P.oneOf
        [ P.succeed WaitAction
            |. P.keyword "wait"
            |. spaces
            |= P.int
        , P.succeed ClickAction
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
                            P.succeed <| SpellAction a
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


type alias SimTimeline =
    { start : SimSnapshot
    , end : SimSnapshot
    , timeline : List ( Scheduler.Event Event, SimSnapshot )
    }


type alias SimSnapshot =
    { now : Timestamp
    , energy : Float
    , energySpent : Float
    , energyEnergonTicks : Int
    , mana : Float
    , manaSpent : Int
    , buffs : Dict String BuffSnapshot
    , fatigue : Dict String FatigueSnapshot
    }


type alias BuffSnapshot =
    { buff : Buff
    , updated : Timestamp
    , stacks : Int
    }


type alias FatigueSnapshot =
    { fatigue : Fatigue
    , updated : Timestamp
    , stacks : Int

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


energonPerFatigue =
    5


energyPerEnergonTick =
    0.025 * energyMax


emptySim : SimSnapshot
emptySim =
    { now = 0
    , energy = 0
    , energySpent = 0
    , energyEnergonTicks = 0
    , mana = 0
    , manaSpent = 0
    , buffs = Dict.empty
    , fatigue = Dict.empty
    }


type Event
    = ActionCompleted SpellAction
    | BuffExpires Buff
    | BuffTicks Buff
    | FatigueExpires Fatigue


run : List SpellAction -> SimTimeline
run acts =
    let
        dur : Duration
        dur =
            acts |> List.map actionDuration |> List.sum

        foldScheduler : SpellAction -> ( Duration, Scheduler Event ) -> ( Duration, Scheduler Event )
        foldScheduler act ( now0, sched ) =
            let
                now =
                    now0 + actionDuration act
            in
            ( now, Scheduler.setTimeout now (ActionCompleted act) sched )

        scheduler : Scheduler Event
        scheduler =
            List.foldl foldScheduler ( 0, Scheduler.empty 0 ) acts |> Tuple.second

        timeline =
            Scheduler.runTimelineUntil dur simStep ( emptySim, scheduler ) |> Tuple.first
    in
    { start = emptySim
    , timeline = timeline
    , end = timeline |> List.Extra.last |> Maybe.Extra.unwrap emptySim Tuple.second
    }


simTimestep : Timestamp -> SimSnapshot -> SimSnapshot
simTimestep time sim =
    { sim
        | now = time
        , mana = toFloat time / 1000 * manaRegen - toFloat sim.manaSpent
        , energy =
            (energyRegen * toFloat time / 1000)
                + (energyPerEnergonTick * toFloat sim.energyEnergonTicks)
                - sim.energySpent
    }


simStep : Scheduler.Event Event -> ( SimSnapshot, Scheduler Event ) -> ( SimSnapshot, Scheduler Event )
simStep simevent ( sim, sched ) =
    let
        time =
            simevent.at

        event =
            simevent.payload
    in
    Tuple.mapFirst (simTimestep time) <|
        case event of
            ActionCompleted (SpellAction spell) ->
                ( sim |> paySpellCosts spell
                , sched
                )
                    |> refreshSpellBuff time spell
                    |> applySpellFatigue time spell

            ActionCompleted _ ->
                -- TODO click energy, lightning free-click buffs
                ( sim, sched )

            BuffExpires buff ->
                ( sim
                    |> applyBuffTick time buff
                    |> (\s -> { s | buffs = sim.buffs |> Dict.remove buff.id })
                , sched
                )

            BuffTicks buff ->
                ( sim |> applyBuffTick time buff
                , sched
                )

            FatigueExpires fat ->
                let
                    sim1 =
                        { sim | fatigue = sim.fatigue |> Dict.update fat.label (Maybe.andThen (expireFatigue time fat)) }
                in
                ( sim1
                , case Dict.get fat.label sim1.fatigue |> Maybe.map .stacks of
                    Nothing ->
                        sched

                    Just _ ->
                        -- there are still fatigue stacks left - schedule another expiration
                        sched |> Scheduler.setTimeout 8000 (FatigueExpires fat)
                )


paySpellCosts : Spell -> SimSnapshot -> SimSnapshot
paySpellCosts spell sim =
    let
        stacks : Float
        stacks =
            GameData.spellFatigue spell
                |> List.map Tuple.first
                |> List.filterMap (\fat -> Dict.get fat.label sim.fatigue)
                |> List.map fatigueStacks
                |> List.sum

        baseCost : Int
        baseCost =
            toFloat (List.length spell.runeCombination) * spell.costMultiplier * 5 |> round

        cost : Float
        cost =
            (1 + stacks * energyCostPerFatigueStack) * toFloat baseCost
    in
    { sim | energySpent = sim.energySpent + cost, manaSpent = sim.manaSpent + spell.manaCost }


applyBuffTick : Timestamp -> Buff -> SimSnapshot -> SimSnapshot
applyBuffTick time buff sim =
    case buff.id of
        "buff:energon" ->
            case Dict.get buff.id sim.buffs of
                Nothing ->
                    sim

                Just { stacks } ->
                    { sim
                        | fatigue =
                            sim.fatigue
                                |> Dict.Extra.filterMap (\_ -> addFatigueEnergonStack stacks)
                        , energyEnergonTicks = sim.energyEnergonTicks + stacks
                    }

        _ ->
            sim


expireFatigue : Timestamp -> Fatigue -> FatigueSnapshot -> Maybe FatigueSnapshot
expireFatigue time fat snapshot =
    let
        stacks =
            snapshot.stacks - 1
    in
    if stacks <= 0 then
        Nothing

    else
        Just { snapshot | updated = time, stacks = stacks }


applySpellFatigue : Timestamp -> Spell -> ( SimSnapshot, Scheduler Event ) -> ( SimSnapshot, Scheduler Event )
applySpellFatigue time spell state0 =
    let
        applyFatigue : ( Fatigue, Int ) -> ( SimSnapshot, Scheduler Event ) -> ( SimSnapshot, Scheduler Event )
        applyFatigue ( fat, stacks ) ( sim, sched ) =
            -- add fatigue stacks
            ( { sim
                | fatigue =
                    sim.fatigue
                        |> Dict.update fat.label (addFatigueStack time fat stacks >> Just)
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


addFatigueStack : Timestamp -> Fatigue -> Int -> Maybe FatigueSnapshot -> FatigueSnapshot
addFatigueStack time {- $$$ -} fat stacks {- $$$ -} msnapshot =
    case msnapshot of
        Nothing ->
            { updated = time, fatigue = fat, stacks = stacks, energonStacks = 0 }

        Just snapshot ->
            { snapshot | stacks = snapshot.stacks + stacks }


addFatigueEnergonStack : Int -> FatigueSnapshot -> Maybe FatigueSnapshot
addFatigueEnergonStack enstacks snapshot =
    { snapshot | energonStacks = snapshot.energonStacks + enstacks }
        |> normalizeEnergonStacks


normalizeEnergonStacks : FatigueSnapshot -> Maybe FatigueSnapshot
normalizeEnergonStacks snapshot =
    let
        stacks =
            snapshot.stacks - snapshot.energonStacks // energonPerFatigue

        energonStacks =
            snapshot.energonStacks |> modBy energonPerFatigue
    in
    if stacks == snapshot.stacks && energonStacks == snapshot.energonStacks then
        Just snapshot

    else if stacks <= 0 then
        Nothing

    else
        Just { snapshot | stacks = stacks, energonStacks = energonStacks }


refreshSpellBuff : Timestamp -> Spell -> ( SimSnapshot, Scheduler Event ) -> ( SimSnapshot, Scheduler Event )
refreshSpellBuff time spell ( sim, sched ) =
    case Dict.get (String.toLower spell.id) buffsBySpell of
        Just buff ->
            -- add a buff stack
            ( { sim
                | buffs =
                    sim.buffs
                        |> Dict.update buff.id (addBuffStack time buff >> Just)
              }
              -- delay buff expiration/ticks
            , sched
                |> removeBuffEvents buff.id
                |> Scheduler.setTimeout buff.duration (BuffExpires buff)
                |> (\s -> List.foldl (\d -> Scheduler.setTimeout d (BuffTicks buff)) s buff.ticksMillis)
            )

        Nothing ->
            ( sim, sched )


addBuffStack : Timestamp -> Buff -> Maybe BuffSnapshot -> BuffSnapshot
addBuffStack time buff msnapshot =
    case msnapshot of
        Nothing ->
            { updated = time, buff = buff, stacks = 1 }

        Just snapshot ->
            { snapshot
                | updated = time
                , stacks =
                    case buff.maxStacks of
                        Nothing ->
                            snapshot.stacks + 1

                        Just cap ->
                            snapshot.stacks + 1 |> min cap
            }


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


fatigueStacks : FatigueSnapshot -> Float
fatigueStacks s =
    toFloat s.stacks - toFloat s.energonStacks / energonPerFatigue
