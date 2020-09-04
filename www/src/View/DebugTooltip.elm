module View.DebugTooltip exposing (view)

import Dict exposing (Dict)
import GameData exposing (Character, GameData, GameVersionData, NodeType)
import GameData.Stats as Stats exposing (Stat)
import Html as H exposing (..)
import Html.Attributes as A exposing (..)
import Html.Events as E exposing (..)
import List.Extra
import Model exposing (Model, Msg)
import Regex exposing (Regex)
import View.FormatUtil


view : Model -> GameData -> Html msg
view model gameData =
    case GameData.latestVersion gameData of
        Nothing ->
            div [] [ text "no gamedata.version" ]

        Just version ->
            div []
                [ text "Tooltip text debugging tool"
                , Dict.values version.heroes
                    |> List.map (viewCharacter version)
                    |> ul []
                ]


viewCharacter : GameVersionData -> Character -> Html msg
viewCharacter version char =
    li []
        [ text char.name
        , Dict.values char.nodeTypes
            |> List.filter (\n -> Dict.member n.key char.graph.nodesByType)
            |> List.filter (\n -> not <| List.isEmpty n.stats)
            |> List.Extra.uniqueBy (\n -> ( n.name, GameData.tooltip n "???" ))
            |> List.map (viewNode version)
            |> table []
        ]


viewNode : GameVersionData -> NodeType -> Html msg
viewNode version node =
    let
        rawTip =
            GameData.tooltip node "???"

        placeholderTip =
            GameData.tooltipPlaceholder node |> Maybe.withDefault "???"

        nodeStats2 : List Stats.StatTotal
        nodeStats2 =
            node.stats
                |> List.map (Tuple.mapSecond (always 2))
                |> Stats.calcStats version.stats

        replacedTip =
            GameData.tooltipPlaceholder node |> Maybe.withDefault "???" |> GameData.tooltipReplace nodeStats2
    in
    tr []
        [ th [] [ text node.name ]
        , td [] [ text node.key ]
        , td []
            (if rawTip == placeholderTip then
                [ text rawTip ]

             else
                [ div [] [ text rawTip ]
                , div [] [ text placeholderTip ]
                , div [] [ text replacedTip ]
                ]
            )
        , td []
            [ table []
                (nodeStats2
                    |> List.map
                        (\s ->
                            tr []
                                [ td [] [ text <| Stats.statToString s.stat, text ": " ]
                                , td [] [ text "level=", text <| String.fromInt s.level ]
                                , td [] [ text "val=", text <| View.FormatUtil.float 5 s.val ]
                                ]
                        )
                )
            ]
        ]
