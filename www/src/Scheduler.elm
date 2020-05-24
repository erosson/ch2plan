module Scheduler exposing
    ( Scheduler, Event, Timestamp, Duration
    , empty, setTimeout, setInterval, setTimestamp
    , now, size, isEmpty, any
    , filter, filterNot
    , pop, popUntil, step, stepUntil, runUntil, runTimelineUntil
    )

{-| x


# Types

@docs Scheduler, Event, Timestamp, Duration


# Create and insert

@docs empty, setTimeout, setInterval, setTimestamp


# Query

@docs now, size, isEmpty, any


# Update

@docs filter, filterNot


# Executing

@docs pop, popUntil, step, stepUntil, runUntil, runTimelineUntil

-}


type Scheduler e
    = Scheduler (Data e)


type alias Data e =
    { now : Timestamp, events : List (Event e) }


type alias Event e =
    { at : Timestamp, interval : Maybe Duration, payload : e }


type alias Timestamp =
    Int


type alias Duration =
    Int


empty : Timestamp -> Scheduler e
empty t =
    Scheduler { now = t, events = [] }


unwrap : Scheduler e -> Data e
unwrap (Scheduler s) =
    s


now : Scheduler e -> Timestamp
now =
    unwrap >> .now


size : Scheduler e -> Int
size =
    unwrap >> .events >> List.length


isEmpty : Scheduler e -> Bool
isEmpty =
    unwrap >> .events >> List.isEmpty


insert : Event e -> Data e -> Data e
insert event s =
    { s | events = event :: s.events }


setTimeout : Duration -> e -> Scheduler e -> Scheduler e
setTimeout dur payload (Scheduler s) =
    s
        |> insert { at = s.now + dur, interval = Nothing, payload = payload }
        |> Scheduler


setInterval : Duration -> e -> Scheduler e -> Scheduler e
setInterval dur payload (Scheduler s) =
    s
        |> insert { at = s.now + dur, interval = Just dur, payload = payload }
        |> Scheduler


setTimestamp : Timestamp -> e -> Scheduler e -> Maybe (Scheduler e)
setTimestamp ts payload sched =
    let
        dur =
            ts - now sched
    in
    if dur >= 0 then
        Just <| setTimeout dur payload sched

    else
        Nothing


filter : (Event e -> Bool) -> Scheduler e -> Scheduler e
filter pred (Scheduler s) =
    Scheduler { s | events = s.events |> List.filter pred }


filterNot : (Event e -> Bool) -> Scheduler e -> Scheduler e
filterNot pred =
    filter (pred >> not)


any : (Event e -> Bool) -> Scheduler e -> Bool
any pred =
    unwrap >> .events >> List.any pred


pop : Scheduler e -> ( Maybe (Event e), Scheduler e )
pop ((Scheduler s) as sched) =
    let
        loop : Event e -> List (Event e) -> List (Event e) -> List (Event e) -> List (Event e) -> ( Maybe (Event e), Scheduler e )
        loop wnode wleft wright left right =
            case right of
                [] ->
                    ( Just wnode
                    , Scheduler
                        { s
                          -- never go backwards in time. should be impossible, but just in case...!
                            | now = max s.now wnode.at
                            , events =
                                case wnode.interval of
                                    Nothing ->
                                        List.reverse wleft ++ wright

                                    Just dur ->
                                        List.reverse wleft ++ { wnode | at = wnode.at + dur } :: wright
                        }
                    )

                head :: tail ->
                    if head.at < wnode.at then
                        -- head is now winning (soonest; minimum `now`)
                        loop head left tail (head :: left) tail

                    else
                        -- head is *not* winning
                        loop wnode wleft wright (head :: left) tail
    in
    case s.events of
        [] ->
            ( Nothing, sched )

        head :: tail ->
            loop head [] tail [ head ] tail


popUntil : Timestamp -> Scheduler e -> ( Maybe (Event e), Scheduler e )
popUntil until ((Scheduler s0) as sched0) =
    case pop sched0 of
        ( Nothing, Scheduler s ) ->
            ( Nothing, Scheduler { s | now = max s.now until } )

        ( Just event, sched ) as res ->
            if now sched > until then
                -- rollback: don't pop any later than `until`!
                ( Nothing, Scheduler { s0 | now = max s0.now until } )

            else
                res


step : (Event e -> ( s, Scheduler e ) -> ( s, Scheduler e )) -> ( s, Scheduler e ) -> ( s, Scheduler e )
step updater ( state, sched0 ) =
    case pop sched0 of
        ( Nothing, sched1 ) ->
            ( state, sched1 )

        ( Just event, sched1 ) ->
            updater event ( state, sched1 )


stepUntil : Timestamp -> (Event e -> ( s, Scheduler e ) -> ( s, Scheduler e )) -> ( s, Scheduler e ) -> ( s, Scheduler e )
stepUntil time updater ( state, sched0 ) =
    case popUntil time sched0 of
        ( Nothing, sched1 ) ->
            ( state, sched1 )

        ( Just event, sched1 ) ->
            updater event ( state, sched1 )


runUntil : Timestamp -> (Event e -> ( s, Scheduler e ) -> ( s, Scheduler e )) -> ( s, Scheduler e ) -> ( s, Scheduler e )
runUntil time updater ( state, sched0 ) =
    case popUntil time sched0 of
        ( Nothing, sched1 ) ->
            ( state, sched1 )

        ( Just event, sched1 ) ->
            updater event ( state, sched1 ) |> runUntil time updater


runTimelineUntil : Timestamp -> (Event e -> ( s, Scheduler e ) -> ( s, Scheduler e )) -> ( s, Scheduler e ) -> ( List ( Event e, s ), Scheduler e )
runTimelineUntil time updater =
    let
        loop timelineEntries ( state0, sched0 ) =
            case popUntil time sched0 of
                ( Nothing, sched1 ) ->
                    ( List.reverse timelineEntries, sched1 )

                ( Just event, sched1 ) ->
                    let
                        ( state2, sched2 ) =
                            updater event ( state0, sched1 )
                    in
                    loop (( event, state2 ) :: timelineEntries) ( state2, sched2 )
    in
    loop []
