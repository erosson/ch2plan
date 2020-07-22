module View.Runecorder exposing (view)

import Dict exposing (Dict)
import GameData exposing (GameData)
import Html as H exposing (..)
import Html.Attributes as A exposing (..)
import Html.Events as E exposing (..)
import Maybe.Extra
import Model exposing (Model, Msg)
import Model.Runecorder as Runecorder exposing (Duration, Timestamp)
import Route exposing (Route)
import Scheduler exposing (Scheduler)
import Set exposing (Set)


view : Model -> GameData -> Html Msg
view model gameData =
    case GameData.wizardSpells gameData of
        Nothing ->
            div [] [ text "no such hero" ]

        Just ( char, spells ) ->
            viewBody model char spells


viewBody : Model -> GameData.Character -> Dict String GameData.Spell -> Html Msg
viewBody model char spells =
    div []
        [ h1 [] [ text "Runecorder planner" ]
        , p [] [ text "Describe your runecorder plan below. I'll output a timeline showing the resources you'll spend, what will happen when, and the buttons you'll press to record it." ]
        , p [] [ text "Use the \"insert an action\" buttons below to get started!" ]
        , div
            [ style "width" "45%"

            -- , style "display" "inline-block"
            , style "float" "left"
            , style "padding" "0.5em"
            ]
            (viewEditor model.runecorderSource ++ viewSpellButtons char)
        , div
            [ style "width" "45%"

            -- , style "display" "inline-block"
            , style "float" "left"
            , style "padding" "0.5em"
            ]
            (viewSimulationResult model.runecorderSim)
        ]


viewEditor : String -> List (Html Msg)
viewEditor source =
    [ div []
        [ textarea
            [ rows 40
            , style "padding" "0"
            , style "margin" "0"
            , style "border" "0"
            , style "width" "100%"
            , onInput Model.RunecorderInput
            , onBlur Model.RunecorderRun
            , value source
            ]
            []
        ]
    , div [] [ button [ onClick Model.RunecorderRun ] [ text "Run" ] ]
    ]


viewSimulationResult : ( String, Result (List Runecorder.DeadEnd) Runecorder.SimTimeline ) -> List (Html msg)
viewSimulationResult ( source, result ) =
    case result of
        Err [] ->
            -- initial state, or invalid gamedata/couldn't find spells
            []

        Err deadEnds ->
            [ div [] [ text "Error" ]
            , ul [ style "list-style-type" "none" ]
                (deadEnds
                    |> List.map
                        (\deadEnd ->
                            li []
                                [ blockquote [] [ code [] [ text <| Runecorder.deadEndToSourceLine source deadEnd ] ]
                                , text <| Runecorder.deadEndToString deadEnd
                                ]
                        )
                )
            ]

        Ok sim ->
            [ div [] (viewSimulation sim)

            --, ul []
            --    (lines
            --        |> List.map viewParsedLine
            --        |> List.map (li [])
            --    )
            ]


viewSimulation : Runecorder.SimTimeline -> List (Html msg)
viewSimulation sim =
    [ div [] [ text "Duration: ", viewTimestamp sim.end.now ]
    , div [] (viewResource " mana" sim.end.mana)
    , div [] (viewResource " energy" sim.end.energy)

    -- TODO this doesn't correctly represent fatigue when looping - we might recover some fatigue at the start of the loop!
    -- still, it's close enough for the common blast -> rest cycle.
    , div []
        (List.map
            (\fat ->
                Dict.get fat.label sim.end.fatigue
                    |> Maybe.Extra.unwrap 0 Runecorder.fatigueStacks
                    |> (*) -1
                    |> viewResource (" " ++ fat.label ++ " fatigue")
                    |> div []
            )
            GameData.fatigues
        )
    , if Runecorder.isResourceNeutral sim.end then
        div [] [ span [ style "color" "lightgreen" ] [ text "🗹" ], text " Resource-neutral, yay! You can safely loop this forever." ]

      else
        case Runecorder.outOfManaDurationEstimate sim.end of
            Just { duration, cycles } ->
                div [ style "color" "red" ]
                    [ text "🗷"
                    , text " Not resource-neutral! Out of mana in "
                    , viewDuration duration
                    , text ", or about "
                    , text <| String.fromInt <| floor cycles
                    , text " cycles. Try to win before that."
                    ]

            Nothing ->
                div [ style "color" "red" ] [ text "🗷", text " Not resource-neutral! Be careful looping this for a long time." ]
    , table [ class "runecorder-timeline" ]
        (sim.timeline
            |> List.map viewLogEntry
            |> List.filter ((/=) [])
            |> List.map (tr [])
        )
    ]


viewResource : String -> Float -> List (Html msg)
viewResource label n =
    if n >= 0 then
        [ div [] [ text "+", text <| String.fromFloat n, text label ] ]

    else
        [ div [ style "color" "red" ] [ text <| String.fromFloat n, text label ] ]


viewLogEntry : ( Scheduler.Event Runecorder.Event, Runecorder.SimSnapshot ) -> List (Html msg)
viewLogEntry ( { at, payload }, snapshot ) =
    case payload of
        -- Err err ->
        -- [ code [] [ text "error: ", text err ] ]
        Runecorder.ActionCompleted act ->
            case act of
                Runecorder.WaitAction ms ->
                    [ td [] [ viewTimestamp at ]
                    , td [] [ text "Waited ", text <| String.fromFloat (toFloat ms / 1000), text " sec" ]
                    ]

                Runecorder.ClickAction ->
                    [ td [] [ viewTimestamp at ], td [] [ text "Clicked" ] ]

                Runecorder.SpellAction spell ->
                    [ td [] [ viewTimestamp at ]
                    , td []
                        [ text "Cast "
                        , code [] [ text spell.displayName ]
                        ]
                    , td [ style "color" "lightgreen" ]
                        [ kbd [] [ spell.runeCombination |> List.map String.fromInt |> String.join " " |> text ]
                        ]
                    ]

        Runecorder.BuffExpires buff ->
            [ td [ style "color" "yellow" ] [ viewTimestamp at ]
            , td [ style "color" "yellow" ] [ text "Expired buff: ", code [] [ text buff.id ] ]
            ]

        Runecorder.BuffTicks buff ->
            if buff.id == "buff:energon" then
                [ td [] [ viewTimestamp at ]
                , td [] [ text "Ticked ", code [] [ text "Energon Cube" ] ]
                ]

            else
                [ td [] [ viewTimestamp at ]
                , td [] [ text "Ticked buff: ", code [] [ text buff.id ] ]
                ]

        _ ->
            []


viewTimestamp : Timestamp -> Html msg
viewTimestamp time =
    let
        ms =
            time |> modBy 1000

        s =
            time // 1000 |> modBy 60

        m =
            -- time // (1000 * 60) |> modBy 60
            time // (1000 * 60)

        -- h =
        -- time // (1000 * 60 * 60)
    in
    -- [ ( 2, h )
    [ ( 2, m )
    , ( 2, s )
    , ( 4, ms )
    ]
        |> List.map (\( digits, val ) -> val |> String.fromInt |> String.padLeft digits '0')
        |> String.join ":"
        |> (\str -> code [] [ text str ])


viewDuration : Duration -> Html msg
viewDuration =
    viewTimestamp


viewSpellButtons : GameData.Character -> List (Html Msg)
viewSpellButtons char =
    [ text "Insert an action:"
    , div []
        [ button [ onClick <| Model.RunecorderAppend "click;" ] [ text "Click" ]
        , button [ onClick <| Model.RunecorderAppend "wait 3000;" ] [ text "Wait 3 seconds (3000 millis)" ]
        , button [ onClick <| Model.RunecorderAppend "loop 3 {\n  // Add some looped actions between the { braces }\n  \n};" ] [ text "Loop actions 3 times" ]
        ]
    , div []
        (char.spells
            |> List.filter (\s -> Set.singleton 7 == s.types)
            |> List.map viewSpellEntry
        )
    , div []
        (GameData.fatigues
            |> List.map
                (\f ->
                    char.spells
                        |> List.filter (\s -> Set.singleton f.ord == s.types)
                        |> List.map viewSpellEntry
                        |> List.map (\b -> div [] [ b ])
                        |> div [ style "display" "inline-block" ]
                )
        )
    , div []
        (char.spells
            |> List.filter (\s -> Set.size s.types > 1)
            |> List.map viewSpellEntry
        )
    , text "Complete example scripts:"
    , div []
        [ button [ onClick <| Model.RunecorderAppend Runecorder.example1 ] [ text "Resource-neutral Ice1 spam" ]
        ]
    ]


viewSpellEntry : GameData.Spell -> Html Msg
viewSpellEntry s =
    let
        lineIf : Bool -> List String -> List String
        lineIf b l =
            if b then
                l

            else
                []

        energy =
            toFloat (List.length s.runeCombination) * s.costMultiplier * 5 |> round

        damage =
            (2 ^ List.length s.runeCombination |> toFloat) * (25.0 / 4) * s.damageMultiplier

        durationSecs =
            toFloat (Runecorder.duration s) / 1000

        fats =
            GameData.spellFatigue s

        lines : List (List String)
        lines =
            [ []
            , [ s.id ]

            -- , lineIf (s.description /= "") [ text s.description ]
            -- , [ text "Runes: ", kbd [] [ s.runeCombination |> List.map String.fromInt |> String.join " " |> text ] ]
            -- , lineIf (s.damageMultiplier > 0) [ text <| "Damage: ×" ++ String.fromFloat damage ]
            , lineIf (durationSecs > 0) [ "Cast time: " ++ String.fromFloat durationSecs ++ "s" ]
            , lineIf (s.manaCost > 0) [ "Mana cost: " ++ String.fromInt s.manaCost ]
            , lineIf (energy > 0) [ "Energy cost: " ++ String.fromInt energy ]
            , lineIf (fats /= [])
                [ "Fatigue: "
                , fats
                    |> List.map (\( fat, val ) -> String.fromInt val ++ "× " ++ fat.label)
                    |> String.join ", "
                ]
            ]

        txt : String
        txt =
            lines |> List.filter ((/=) []) |> List.map (String.join "") |> String.join "\n"
    in
    button [ title txt, onClick <| Model.RunecorderAppend <| s.id ++ ";" ] [ text s.displayName ]
