module View.Spreadsheet exposing (view, format)

import Dict as Dict exposing (Dict)
import Html as H
import Html.Attributes as A
import Html.Events as E
import Route
import Model as M


view : M.Model -> Route.HomeParams -> H.Html msg
view model params =
    H.div [ A.class "spreadsheet" ]
        [ H.p [ A.class "help" ] [ H.text "Copy the text below (click the text box, ctrl+a, ctrl+c), and paste it into your favorite spreadsheet-based Clicker Heroes 2 calculator (ctrl+v)." ]
        , H.p [ A.class "help" ] [ H.a [ A.target "_blank", A.href "https://docs.google.com/spreadsheets/d/16oUAO0uxAChI0P9rUGNTxCIvlX9wM97ljOcUGf8DXCA" ] [ H.text "Writing your own spreadsheet? Here's an example showing how to use this." ] ]
        , H.textarea [ A.class "tsv" ]
            [ H.text
                (case M.parseStatsSummary model params of
                    Err err ->
                        "error: " ++ err

                    Ok stats ->
                        format model stats
                )
            ]
        ]


format : M.Model -> M.StatsSummary -> String
format _ stats =
    formatRows stats
        |> (::) [ "id", "count", "label", "", "build planner:", "https://ch2.erosson.org" ++ (Route.stringify <| Route.Home stats.params) ]
        |> List.map (String.join "\t")
        |> String.join "\n"


formatRows : M.StatsSummary -> List (List String)
formatRows stats =
    let
        mapCounts count nodeType =
            ( nodeType.key, count )

        counts =
            stats.nodes |> List.map (uncurry mapCounts) |> Dict.fromList
    in
        stats.char.nodeTypes
            |> Dict.values
            |> List.sortBy .key
            |> List.map
                (\node ->
                    [ node.key
                    , counts |> Dict.get node.key |> Maybe.withDefault 0 |> toString
                    , "'" ++ node.name
                    ]
                )
