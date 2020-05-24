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
        [ h1 [] [ text "Runecorder" ]

        -- , div [ class "spells-summary" ]
        , div [ style "float" "left" ]
            [ text "Actions:"
            , ul []
                ([ li []
                    [ button [ onClick <| Model.RunecorderAppend "click;" ] [ text "Click" ]
                    ]
                 , li []
                    [ button [ onClick <| Model.RunecorderAppend "wait 3000;" ] [ text "Wait 3 seconds (3000 millis)" ]
                    ]
                 , li []
                    [ button [ onClick <| Model.RunecorderAppend "loop 3 {\n  // Add some looped actions below:\n  \n};" ] [ text "Loop actions 3 times" ]
                    ]
                 ]
                    ++ List.map viewSpellEntry char.spells
                )
            ]
        , div [ style "float" "right" ]
            (case model.runecorderSim of
                ( _, Err [] ) ->
                    -- initial state, or invalid gamedata/couldn't find spells
                    []

                ( source, Err deadEnds ) ->
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

                ( _, Ok sim ) ->
                    [ div [] (viewSimulation sim)

                    --, ul []
                    --    (lines
                    --        |> List.map viewParsedLine
                    --        |> List.map (li [])
                    --    )
                    ]
            )
        , div []
            [ textarea
                [ rows 40
                , cols 80
                , onInput Model.RunecorderInput
                , onBlur Model.RunecorderRun
                , value model.runecorderSource
                ]
                []
            ]
        , div [] [ button [ onClick Model.RunecorderRun ] [ text "Run" ] ]
        ]


viewSimulation : Runecorder.SimTimeline -> List (Html msg)
viewSimulation sim =
    [ div [] [ text "Duration: ", viewTimestamp sim.end.now ]
    , div [] (viewResource " mana" sim.end.mana)
    , div [] (viewResource " energy" sim.end.energy)

    -- TODO this doesn't correctly represent fatigue when looping - we might recover some fatigue at the start of the loop!
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
    , ul []
        (sim.timeline
            |> List.map viewLogEntry
            |> List.filter ((/=) [])
            |> List.map (li [])
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
                    [ viewTimestamp at, text ": Waited ", text <| String.fromFloat (toFloat ms / 1000), text " sec" ]

                Runecorder.ClickAction ->
                    [ viewTimestamp at, text ": Clicked" ]

                Runecorder.SpellAction spell ->
                    [ viewTimestamp at
                    , text ": Cast "
                    , code [] [ text spell.displayName ]
                    , text ": "
                    , div [] [ kbd [ style "color" "green" ] [ spell.runeCombination |> List.map String.fromInt |> String.join " " |> text ] ]
                    ]

        Runecorder.BuffExpires buff ->
            [ viewTimestamp at, text ": Expired buff: ", code [] [ text buff.id ] ]

        Runecorder.BuffTicks buff ->
            if buff.id == "buff:energon" then
                [ viewTimestamp at, text ": Ticked ", code [] [ text "Energon Cube" ] ]

            else
                [ viewTimestamp at, text ": Ticked buff: ", code [] [ text buff.id ] ]

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


viewSpellEntry : GameData.Spell -> Html Msg
viewSpellEntry s =
    let
        lineIf : Bool -> List (Html msg) -> List (Html msg)
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

        lines : List (List (Html msg))
        lines =
            [ []
            , [ text s.id ]

            -- , lineIf (s.description /= "") [ text s.description ]
            -- , [ text "Runes: ", kbd [] [ s.runeCombination |> List.map String.fromInt |> String.join " " |> text ] ]
            -- , lineIf (s.damageMultiplier > 0) [ text <| "Damage: ×" ++ String.fromFloat damage ]
            , lineIf (durationSecs > 0) [ text <| "Cast time: " ++ String.fromFloat durationSecs ++ "s" ]
            , lineIf (s.manaCost > 0) [ text <| "Mana cost: " ++ String.fromInt s.manaCost ]
            , lineIf (energy > 0) [ text <| "Energy cost: " ++ String.fromInt energy ]
            , lineIf (fats /= [])
                [ text <| "Fatigue: "
                , fats
                    |> List.map (\( fat, val ) -> String.fromInt val ++ "× " ++ fat.label)
                    |> String.join ", "
                    |> text
                ]
            ]
    in
    li []
        [ button [ onClick <| Model.RunecorderAppend <| s.id ++ ";" ] [ text s.displayName ]

        -- , ul [] (lines |> List.filter ((/=) []) |> List.map (li []))
        ]
