module View.DebugTooltip exposing (view)

import Dict exposing (Dict)
import GameData exposing (Character, GameData, GameVersionData, NodeType)
import Html as H exposing (..)
import Html.Attributes as A exposing (..)
import Html.Events as E exposing (..)
import List.Extra
import Model exposing (Model, Msg)
import Regex exposing (Regex)


view : Model -> GameData -> Html msg
view model gameData =
    case GameData.latestVersion gameData of
        Nothing ->
            div [] [ text "no gamedata.version" ]

        Just version ->
            div []
                [ text "debugtooltip"
                , Dict.values version.heroes
                    |> List.map viewCharacter
                    |> ul []
                ]


viewCharacter : Character -> Html msg
viewCharacter char =
    li []
        [ text char.name
        , Dict.values char.nodeTypes
            |> List.filter (\n -> Dict.member n.key char.graph.nodesByType)
            |> List.filter (\n -> not <| List.isEmpty n.stats)
            |> List.Extra.uniqueBy (\n -> ( n.name, GameData.tooltip n "???" ))
            |> List.map viewNode
            |> table []
        ]


viewNode : NodeType -> Html msg
viewNode node =
    let
        raw =
            GameData.tooltip node "???"

        placeholdered =
            GameData.tooltipPlaceholder node |> Maybe.withDefault "???"
    in
    tr []
        [ th [] [ text node.name ]
        , td [] [ text node.key ]
        , td []
            (if raw == placeholdered then
                [ text raw ]

             else
                [ div [] [ text raw ]
                , div [] [ text placeholdered ]
                ]
            )
        , td [] [ text <| Debug.toString node.stats ]
        ]
