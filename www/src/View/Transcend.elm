module View.Transcend exposing (view)

import Dict exposing (Dict)
import GameData exposing (Character, GameData, GameVersionData)
import GameData.Stats as Stats exposing (Stat(..))
import Html as H exposing (..)
import Html.Attributes as A exposing (..)
import Html.Events as E exposing (..)
import Maybe.Extra
import Model exposing (Model, Msg)
import Model.Graph exposing (GraphModel)
import Model.Skill as Skill
import NumberSuffix
import Result.Extra
import Route
import Set exposing (Set)
import Time
import View.Spreadsheet
import View.Util


type alias TranscensionPerk =
    { key : Int
    , data : GameData.TranscensionPerk
    , stats : Stats.TranscensionPerk
    }


zipPerks : Character -> Route.HomeParams -> GameVersionData -> Result String (List TranscensionPerk)
zipPerks char params game =
    case Dict.get params.hero game.stats.characters of
        Nothing ->
            Err "no char stats"

        Just charStats ->
            char.transcensionPerks
                |> Dict.toList
                |> List.map
                    (\( key, data ) ->
                        case Dict.get key charStats.transcensionPerks of
                            Nothing ->
                                Err <| "no such perk: " ++ String.fromInt key

                            Just s ->
                                Ok { key = key, data = data, stats = s }
                    )
                |> Result.Extra.combine


perkLevel : TranscensionPerk -> Model -> Int
perkLevel perk =
    .transcendPerks >> Dict.get perk.key >> Maybe.withDefault 0


view : Html Msg -> Model -> GameData -> Route.HomeParams -> Html Msg
view header model gameData params =
    case ( model.graph, model.error ) of
        ( Nothing, Just err ) ->
            -- div [] [ text <| Debug.toString err ]
            div [] [ text "???no graph???" ]

        ( Nothing, Nothing ) ->
            div [] [ text "???no graph???" ]

        ( Just graph, _ ) ->
            case zipPerks graph.char params graph.game of
                Err err ->
                    div [] [ text err ]

                Ok perks ->
                    let
                        perkLevels =
                            perks |> List.map (\p -> ( p, perkLevel p model ))
                    in
                    div []
                        [ viewHeader header params graph perkLevels
                        , ul [ class "transcend-perks" ]
                            (List.map (viewPerk params graph) perkLevels)
                        ]


viewHeader : Html msg -> Route.HomeParams -> GraphModel -> List ( TranscensionPerk, Int ) -> Html msg
viewHeader header params { game, char } perks =
    let
        totalCost =
            perks |> List.map (\( p, lvl ) -> totalLevelCost p.stats lvl) |> List.sum
    in
    div [ class "transcend-perks-header" ]
        [ header
        , p [] [ a [ Route.href <| Route.Home params ] [ text "View Skill Tree" ] ]
        , div [] [ viewInt totalCost, text " hero souls spent" ]
        ]


viewPerk : Route.HomeParams -> GraphModel -> ( TranscensionPerk, Int ) -> Html Msg
viewPerk params { game, char } ( perk, level ) =
    let
        ( g, ga ) =
            perk.stats.costFunction

        debugText =
            String.join "\n" <|
                [ "cost: " ++ Stats.growthToString g ++ "(" ++ String.join ", " (List.map String.fromFloat ga) ++ ")" ]
                    ++ (case perk.stats.trait of
                            Nothing ->
                                []

                            Just t ->
                                [ "trait: " ++ t ]
                       )
    in
    li []
        [ div [ class "transcend-perk-level" ]
            [ input
                [ type_ "number"
                , A.min "0"
                , A.max "6666"
                , onInput <| Model.TranscendPerkInput perk.key
                , value <| String.fromInt level
                ]
                []
            ]
        , div
            [ class "transcend-perk-body"
            , title debugText
            ]
            [ h4 [] [ text perk.data.name ]
            , p [] [ text perk.data.description ]

            -- , div [] [ text <| Debug.toString perk.stats.costFunction ]
            -- , div [] [ text <| Debug.toString perk ]
            , div [ class "cost" ]
                [ [ nextLevelCost perk.stats level
                        |> Maybe.map
                            (\c ->
                                formatInt c ++ " souls for next level"
                            )
                  , let
                        c =
                            totalLevelCost perk.stats level
                    in
                    if c <= 0 then
                        Nothing

                    else
                        Just <| formatInt c ++ " souls spent"
                  ]
                    |> List.filterMap identity
                    |> String.join "; "
                    |> text
                ]
            ]
        , div [ style "clear" "left" ] []
        ]


formatInt =
    NumberSuffix.formatInt NumberSuffix.standardConfig


viewInt =
    text << formatInt


totalLevelCost : Stats.TranscensionPerk -> Int -> Int
totalLevelCost perk level =
    List.range 0 (level - 1)
        |> List.filterMap (nextLevelCost perk)
        |> List.sum


nextLevelCost : Stats.TranscensionPerk -> Int -> Maybe Int
nextLevelCost perk level =
    let
        levelf =
            toFloat level
    in
    case perk.costFunction of
        ( Stats.Constant, [ cost ] ) ->
            if level == 0 then
                cost |> ceiling |> Just

            else
                Nothing

        ( Stats.ExponentialMultiplier, [ pow ] ) ->
            (pow ^ levelf) |> ceiling |> Just

        ( Stats.LinearExponential, [ base, incr, pow ] ) ->
            (base + levelf) * (pow ^ levelf) |> ceiling |> Just

        _ ->
            Nothing
