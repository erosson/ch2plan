module View.Spreadsheet exposing (format, view)

import Dict exposing (Dict)
import Dict.Extra
import GameData exposing (GameData, NodeId, NodeType)
import Html as H exposing (..)
import Html.Attributes as A exposing (..)
import Html.Events as E exposing (..)
import Maybe.Extra
import Model exposing (Model)
import Route exposing (Route)
import Set exposing (Set)


view : Model -> GameData -> Route.HomeParams -> Html msg
view model gameData params =
    let
        url =
            "https://ch2.erosson.org" ++ (Route.stringify <| Route.Home params)
    in
    div [ class "spreadsheet" ]
        ([ p [ class "help" ] [ text "Copy the text below (click the text box, ctrl+a, ctrl+c), and paste it into your favorite spreadsheet-based Clicker Heroes 2 calculator (ctrl+v)." ]
         , p [ class "help" ]
            [ a [ target "_blank", href "https://docs.google.com/spreadsheets/d/16oUAO0uxAChI0P9rUGNTxCIvlX9wM97ljOcUGf8DXCA" ]
                [ text "Writing your own spreadsheet? Here's an example showing how to use this." ]
            ]
         , textarea [ class "tsv" ]
            [ text
                (case Model.parseStatsSummary model gameData params of
                    Err err ->
                        "error: " ++ err

                    Ok stats ->
                        format url model stats
                )
            ]
         ]
            ++ (if model.features.transcendNodes then
                    [ div [] [ text "Transcended node levels:" ]
                    , textarea [ class "tsv" ]
                        [ text
                            (case formatTranscendNodes url model of
                                Err err ->
                                    "error: " ++ err

                                Ok transNodes ->
                                    transNodes
                            )
                        ]
                    ]

                else
                    []
               )
        )


formatTranscendNodes : String -> Model -> Result String String
formatTranscendNodes url model =
    case model.graph of
        Nothing ->
            Err "no graph"

        Just { char, selected } ->
            Dict.toList model.transcendNodes
                |> List.map
                    (\( id, level ) ->
                        if level <= 1 then
                            []

                        else
                            let
                                isSelected =
                                    if Set.member id selected.set then
                                        "TRUE"

                                    else
                                        "FALSE"
                            in
                            case Dict.get id char.graph.nodes of
                                Nothing ->
                                    [ String.fromInt id
                                    , String.fromInt level
                                    , isSelected
                                    ]

                                Just node ->
                                    [ String.fromInt id
                                    , String.fromInt level
                                    , isSelected
                                    , node.val.key
                                    , "'" ++ node.val.name
                                    ]
                    )
                |> List.filter ((/=) [])
                |> (::) [ "node-id", "level", "is-selected", "node-type", "label", "", "build planner:", url ]
                |> formatCells
                |> Ok


format : String -> Model -> Model.StatsSummary -> String
format url model stats =
    formatRows model stats
        |> (::)
            (if model.features.transcendNodes then
                [ "id", "trnslvl", "count", "label", "is-upgradable", "", "build planner:", url ]

             else
                [ "id", "count", "label", "", "build planner:", url ]
            )
        |> formatCells


formatCells : List (List String) -> String
formatCells =
    List.map (String.join "\t") >> String.join "\n"


formatRows : Model -> Model.StatsSummary -> List (List String)
formatRows model stats =
    let
        counts : Dict String (List Model.NodeTypeSummary)
        counts =
            stats.nodes |> Dict.Extra.groupBy (\s -> s.nodeType.key)

        rowdata : List ( NodeType, Maybe Model.NodeTypeSummary )
        rowdata =
            stats.char.nodeTypes
                |> Dict.values
                |> List.sortBy .key
                |> List.concatMap
                    (\node ->
                        case Dict.get node.key counts of
                            Nothing ->
                                [ ( node, Nothing ) ]

                            Just [] ->
                                [ ( node, Nothing ) ]

                            Just cs ->
                                cs |> List.map (\c -> ( node, Just c ))
                    )
    in
    rowdata
        |> List.map
            (\( node, statcount ) ->
                List.filterMap identity
                    [ Just node.key
                    , if model.features.transcendNodes then
                        if node.flammable then
                            Just ""

                        else
                            statcount
                                |> Maybe.Extra.unwrap 1 .transcendLevel
                                |> String.fromInt
                                |> Just

                      else
                        Nothing
                    , statcount
                        |> Maybe.Extra.unwrap 0 .count
                        |> String.fromInt
                        |> Just
                    , "'" ++ node.name |> Just
                    , if model.features.transcendNodes then
                        if node.flammable then
                            Just "FALSE"

                        else
                            Just "TRUE"

                      else
                        Nothing
                    ]
            )
