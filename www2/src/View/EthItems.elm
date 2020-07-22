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
                    , th [] [ text "gild" ]
                    , th [] [ text "stat-src" ]
                    , th [] [ text "->" ]
                    , th [] [ text "rate" ]
                    , th [] [ text "stat-dest" ]
                    , th [] [ text "total" ]
                    , th [] [ text "uniqueStat" ]
                    ]
                    :: (items |> Dict.values |> List.map (\item -> tr [] (viewItem item)))
                )


viewItem : EtherealItem -> List (Html msg)
viewItem item =
    [ td [] [ text item.id ]
    , td []
        [ text <|
            case item.slot of
                0 ->
                    "Weapon"

                1 ->
                    "Helmet"

                2 ->
                    "Chest"

                3 ->
                    "Ring"

                4 ->
                    "Pants"

                5 ->
                    "Gloves"

                6 ->
                    "Feet"

                7 ->
                    "Back"

                _ ->
                    String.fromInt item.slot
        ]
    , td [] [ text <| String.fromInt item.rarity ]
    , td [] [ text <| String.fromInt item.mainStat.gild ]
    , td [ style "float" "right" ]
        [ case SaveFile.sourceStat item.mainStat of
            Nothing ->
                i [] [ text "unknown" ]

            Just src ->
                text src
        ]
    , td [] [ text "->" ]
    , td [] [ text <| String.slice 0 4 <| String.fromFloat item.mainStat.calculatedExchangeRate ]
    , td [] [ text <| String.replace "ethereal" "" item.mainStat.key ]
    , td [] [ text <| String.fromFloat item.mainStat.calculatedValue ]
    , td []
        (case item.uniqueStat of
            Nothing ->
                []

            Just stat ->
                [ text stat.key ]
        )
    ]
