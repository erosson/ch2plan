module View.EthItems exposing (view)

import Dict exposing (Dict)
import Html as H exposing (..)
import Html.Attributes as A exposing (..)
import Html.Events as E exposing (..)
import Model exposing (Model)
import SaveFile exposing (EtherealItem, EtherealStat)


view : Model -> Html msg
view model =
    case model.etherealItemInventory of
        Nothing ->
            p [ class "error" ] [ text "No ethereal items loaded. Try importing a saved game." ]

        Just items ->
            table []
                (tr []
                    [ th [] [ text "item id" ]
                    , th [] [ text "slot" ]
                    , th [] [ text "rarity" ]
                    , th [] [ text "icon id" ]
                    , th [] [ text "gild" ]
                    , th [] [ text "stat-src" ]
                    , th [] [ text "->" ]
                    , th [] [ text "stat-dest" ]
                    , th [] [ text "rate" ]
                    , th [] [ text "total" ]
                    , th [] [ text "uniqueStat" ]
                    ]
                    :: (items |> Dict.values |> List.map (\item -> tr [] (viewItem item)))
                )


viewItem : EtherealItem -> List (Html msg)
viewItem item =
    [ td [] [ text item.id ]
    , td [] [ text <| String.fromInt item.slot ]
    , td [] [ text <| String.fromInt item.rarity ]
    , td [] [ text <| String.fromInt item.iconId ]
    , td [] [ text <| String.fromInt item.mainStat.gild ]
    , td [ style "float" "right" ]
        [ case SaveFile.sourceStat item.mainStat of
            Nothing ->
                i [] [ text "unknown" ]

            Just src ->
                text src
        ]
    , td [] [ text "->" ]
    , td [] [ text item.mainStat.key ]
    , td [] [ text <| String.fromFloat item.mainStat.calculatedExchangeRate ]
    , td [] [ text <| String.fromFloat item.mainStat.calculatedValue ]
    , td []
        (case item.uniqueStat of
            Nothing ->
                []

            Just stat ->
                [ text stat.key ]
        )
    ]
