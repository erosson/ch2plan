module Scheduler exposing
    ( Duration
    , Scheduler
    , Timestamp
    , any
    , empty
    , filter
    , filterNot
    , isEmpty
    , pop
    , popUntil
    , runUntil
    , setInterval
    , setTimeout
    , setTimestamp
    , size
    , step
    , stepUntil
    )


type Scheduler a
    = Scheduler (Data a)


type alias Data a =
    { now : Timestamp, events : List (Event a) }


type alias Event a =
    { at : Timestamp, interval : Maybe Duration, payload : a }


type alias Timestamp =
    Int


type alias Duration =
    Int


empty : Timestamp -> Scheduler a
empty t =
    Scheduler { now = t, events = [] }


unwrap : Scheduler a -> Data a
unwrap (Scheduler s) =
    s


now : Scheduler a -> Timestamp
now =
    unwrap >> .now


size : Scheduler a -> Int
size =
    unwrap >> .events >> List.length


isEmpty : Scheduler a -> Bool
isEmpty =
    unwrap >> .events >> List.isEmpty


insert : Event a -> Data a -> Data a
insert event s =
    { s | events = event :: s.events }


setTimeout : Duration -> a -> Scheduler a -> Scheduler a
setTimeout dur payload (Scheduler s) =
    s
        |> insert { at = s.now + dur, interval = Nothing, payload = payload }
        |> Scheduler


setInterval : Duration -> a -> Scheduler a -> Scheduler a
setInterval dur payload (Scheduler s) =
    s
        |> insert { at = s.now + dur, interval = Just dur, payload = payload }
        |> Scheduler


setTimestamp : Timestamp -> a -> Scheduler a -> Maybe (Scheduler a)
setTimestamp ts payload sched =
    let
        dur =
            ts - now sched
    in
    if dur >= 0 then
        Just <| setTimeout dur payload sched

    else
        Nothing


pop : Scheduler a -> ( Maybe a, Scheduler a )
pop ((Scheduler s) as sched) =
    let
        loop : Event a -> List (Event a) -> List (Event a) -> List (Event a) -> List (Event a) -> ( Maybe a, Scheduler a )
        loop wnode wleft wright left right =
            case right of
                [] ->
                    ( Just wnode.payload
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


popUntil : Timestamp -> Scheduler a -> ( Maybe a, Scheduler a )
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


filter : (Event a -> Bool) -> Scheduler a -> Scheduler a
filter pred (Scheduler s) =
    Scheduler { s | events = s.events |> List.filter pred }


filterNot : (Event a -> Bool) -> Scheduler a -> Scheduler a
filterNot pred =
    filter (pred >> not)


any : (Event a -> Bool) -> Scheduler a -> Bool
any pred =
    unwrap >> .events >> List.any pred


step : (Timestamp -> a -> ( b, Scheduler a ) -> ( b, Scheduler a )) -> ( b, Scheduler a ) -> ( b, Scheduler a )
step updater ( state, sched0 ) =
    case pop sched0 of
        ( Nothing, sched1 ) ->
            ( state, sched1 )

        ( Just event, sched1 ) ->
            ( state, sched1 ) |> updater (now sched1) event


stepUntil : Timestamp -> (Timestamp -> a -> ( b, Scheduler a ) -> ( b, Scheduler a )) -> ( b, Scheduler a ) -> ( b, Scheduler a )
stepUntil time updater ( state, sched0 ) =
    case popUntil time sched0 of
        ( Nothing, sched1 ) ->
            ( state, sched1 )

        ( Just event, sched1 ) ->
            ( state, sched1 ) |> updater (now sched1) event


runUntil : Timestamp -> (Timestamp -> a -> ( b, Scheduler a ) -> ( b, Scheduler a )) -> ( b, Scheduler a ) -> ( b, Scheduler a )
runUntil time updater ( state, sched0 ) =
    case popUntil time sched0 of
        ( Nothing, sched1 ) ->
            ( state, sched1 )

        ( Just event, sched1 ) ->
            ( state, sched1 ) |> updater (now sched1) event |> runUntil time updater
