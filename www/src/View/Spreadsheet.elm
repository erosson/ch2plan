module View.Spreadsheet exposing (format, view)

import Dict exposing (Dict)
import GameData exposing (GameData)
import Html as H exposing (..)
import Html.Attributes as A exposing (..)
import Html.Events as E exposing (..)
import Model exposing (Model)
import Route exposing (Route)


view : Model -> GameData -> Route.HomeParams -> Html msg
view model gameData params =
    div [ class "spreadsheet" ]
        [ p [ class "help" ] [ text "Copy the text below (click the text box, ctrl+a, ctrl+c), and paste it into your favorite spreadsheet-based Clicker Heroes 2 calculator (ctrl+v)." ]
        , p [ class "help" ]
            [ a [ target "_blank", href "https://docs.google.com/spreadsheets/d/16oUAO0uxAChI0P9rUGNTxCIvlX9wM97ljOcUGf8DXCA" ]
                [ text "Writing your own spreadsheet? Here's an example showing how to use this." ]
            ]
        , textarea [ class "tsv" ]
            [ text
                (case Model.parseStatsSummary gameData params of
                    Err err ->
                        "error: " ++ err

                    Ok stats ->
                        format model stats
                )
            ]
        ]


format : Model -> Model.StatsSummary -> String
format _ stats =
    formatRows stats
        |> (::) [ "id", "count", "label", "", "build planner:", "https://ch2.erosson.org" ++ (Route.stringify <| Route.Home stats.params) ]
        |> List.map (String.join "\t")
        |> String.join "\n"


formatRows : Model.StatsSummary -> List (List String)
formatRows stats =
    let
        mapCounts count nodeType =
            ( nodeType.key, count )

        counts =
            stats.nodes |> List.map (\( a, b ) -> mapCounts a b) |> Dict.fromList
    in
    stats.char.nodeTypes
        |> Dict.values
        |> List.sortBy .key
        |> List.map
            (\node ->
                [ node.key
                , counts |> Dict.get node.key |> Maybe.withDefault 0 |> String.fromInt
                , "'" ++ node.name
                ]
            )
