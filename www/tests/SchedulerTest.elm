module SchedulerTest exposing (..)

import Expect exposing (Expectation)
import Route exposing (Route)
import Scheduler exposing (Event, Scheduler)
import Test exposing (..)


flags : Test
flags =
    describe "scheduler"
        [ test "pop empty" <|
            \_ ->
                Scheduler.empty 555
                    |> Scheduler.pop
                    |> Expect.equal ( Nothing, Scheduler.empty 555 )
        , test "pop nonempty" <|
            \_ ->
                Scheduler.empty 555
                    |> Scheduler.setTimeout 444 "payload"
                    |> Scheduler.pop
                    |> Expect.equal ( Just <| Event 999 Nothing "payload", Scheduler.empty 999 )
        , test "pop until: ==" <|
            \_ ->
                Scheduler.empty 555
                    |> Scheduler.setTimeout 444 "payload"
                    |> Scheduler.popUntil 999
                    |> Expect.equal ( Just <| Event 999 Nothing "payload", Scheduler.empty 999 )
        , test "pop until: ok" <|
            \_ ->
                Scheduler.empty 555
                    |> Scheduler.setTimeout 444 "payload"
                    |> Scheduler.popUntil 1000
                    |> Expect.equal ( Just <| Event 999 Nothing "payload", Scheduler.empty 999 )
        , test "pop until: too soon" <|
            \_ ->
                Scheduler.empty 555
                    |> Scheduler.setTimeout 444 "payload"
                    |> Scheduler.popUntil 998
                    |> Expect.equal ( Nothing, Scheduler.empty 998 |> Scheduler.setTimeout 1 "payload" )
        , test "pop multiple" <|
            \_ ->
                Scheduler.empty 555
                    |> Scheduler.setTimeout 445 "payload2"
                    |> Scheduler.setTimeout 444 "payload"
                    |> Scheduler.setTimeout 446 "payload3"
                    |> Scheduler.pop
                    |> Expect.equal
                        ( Just <| Event 999 Nothing "payload"
                        , Scheduler.empty 999
                            |> Scheduler.setTimeout 1 "payload2"
                            |> Scheduler.setTimeout 2 "payload3"
                        )
        , test "setInterval" <|
            \_ ->
                Scheduler.empty 555
                    |> Scheduler.setInterval 111 "payload"
                    |> Scheduler.pop
                    |> Expect.equal
                        ( Just <| Event 666 (Just 111) "payload"
                        , Scheduler.empty 666
                            |> Scheduler.setInterval 111 "payload"
                        )
        , test "filter" <|
            \_ ->
                Scheduler.empty 555
                    |> Scheduler.setTimeout 444 "payload"
                    |> Scheduler.setTimeout 445 "payload2"
                    |> Scheduler.filter (\e -> e.payload /= "payload")
                    |> Expect.equal
                        (Scheduler.empty 555
                            |> Scheduler.setTimeout 445 "payload2"
                        )
        , test "runTimelineUntil" <|
            \_ ->
                Scheduler.runTimelineUntil 1000
                    (\e ( state, sched ) -> ( e.payload :: state, sched ))
                    ( []
                    , Scheduler.empty 555
                        |> Scheduler.setTimeout 444 "payload"
                        |> Scheduler.setTimeout 445 "payload2"
                        |> Scheduler.setTimeout 446 "payload3"
                    )
                    |> Expect.equal
                        ( [ ( { at = 999, interval = Nothing, payload = "payload" }, [ "payload" ] )
                          , ( { at = 1000, interval = Nothing, payload = "payload2" }, [ "payload2", "payload" ] )
                          ]
                        , Scheduler.empty 1000 |> Scheduler.setTimeout 1 "payload3"
                        )
        ]
