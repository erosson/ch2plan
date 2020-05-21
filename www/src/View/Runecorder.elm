module View.Runecorder exposing (view)

import Dict exposing (Dict)
import Dict.Extra
import GameData exposing (GameData)
import Html as H exposing (..)
import Html.Attributes as A exposing (..)
import Html.Events as E exposing (..)
import Model exposing (Model, Msg)
import Model.Runecorder as Runecorder exposing (Duration, Timestamp)
import Route exposing (Route)


view : Model -> GameData -> Html Msg
view model gameData =
    case GameData.latestVersion gameData of
        Nothing ->
            div [] [ text "no such version" ]

        Just version ->
            case Dict.get "wizard" version.heroes of
                Nothing ->
                    div [] [ text "no such hero" ]

                Just hero ->
                    viewBody model gameData version hero


viewBody : Model -> GameData -> GameData.GameVersionData -> GameData.Character -> Html Msg
viewBody model gameData version char =
    let
        parsed =
            Runecorder.parse (char.spells |> Dict.Extra.fromListBy (.id >> String.toLower)) model.runecorder

        sim : Runecorder.Simulation
        sim =
            parsed
                |> Result.map Runecorder.unrollStatements
                |> Runecorder.ignoreParseErrors
                |> Runecorder.run
    in
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
            (case parsed of
                Err err ->
                    [ pre [] [ text err ]

                    -- , div [] (viewSimulation sim)
                    ]

                Ok lines ->
                    [ div [] (viewSimulation sim)

                    --, ul []
                    --    (lines
                    --        |> List.map viewParsedLine
                    --        |> List.map (li [])
                    --    )
                    ]
            )
        , div [] [ textarea [ rows 40, cols 80, onInput Model.RunecorderInput, value model.runecorder ] [] ]
        ]


viewSimulation : Runecorder.Simulation -> List (Html msg)
viewSimulation sim =
    [ div [] [ text "Duration: ", viewTimestamp sim.durationMillis ]
    , div [] (viewResource " mana" sim.mana)
    , div [] (viewResource " energy" sim.energy)

    -- TODO this is wrong; we want to know the difference when looping!
    , div []
        (GameData.fatigues
            |> List.map
                (\fat ->
                    Dict.get fat.label sim.fatigueTimelines
                        |> Maybe.andThen (List.reverse >> List.head)
                        |> Maybe.andThen Runecorder.fatigueStacks
                        |> Maybe.withDefault 0
                        |> (*) -1
                        |> viewResource (" " ++ fat.label ++ " fatigue")
                        |> div []
                )
        )
    , ul []
        (sim.log
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


viewLogEntry : ( Timestamp, Runecorder.Event ) -> List (Html msg)
viewLogEntry ( time, event ) =
    case event of
        -- Err err ->
        -- [ code [] [ text "error: ", text err ] ]
        Runecorder.ActionCompleted act ->
            case act of
                Runecorder.WaitAction ms ->
                    [ viewTimestamp time, text ": Waited ", text <| String.fromFloat (toFloat ms / 1000), text " sec" ]

                Runecorder.ClickAction ->
                    [ viewTimestamp time, text ": Clicked" ]

                Runecorder.SpellAction spell ->
                    [ viewTimestamp time, text ": Cast ", code [] [ text spell.displayName ] ]

        Runecorder.BuffExpires buff ->
            [ viewTimestamp time, text ": Expired buff: ", code [] [ text buff.id ] ]

        Runecorder.BuffTicks buff ->
            if buff.id == "buff:energon" then
                [ viewTimestamp time, text ": Ticked ", code [] [ text "Energon Cube" ] ]

            else
                [ viewTimestamp time, text ": Ticked buff: ", code [] [ text buff.id ] ]

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
            (List.length s.runeCombination * s.msecsPerRune |> toFloat) * 0.5 / 1000

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
