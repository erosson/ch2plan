module View.Transcend exposing (view)

import Dict exposing (Dict)
import GameData exposing (Character, GameData, GameVersionData)
import GameData.Stats as Stats exposing (Stat(..))
import Html as H exposing (..)
import Html.Attributes as A exposing (..)
import Html.Events as E exposing (..)
import Maybe.Extra
import Model exposing (Model)
import Model.Skill as Skill
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


view : Model -> GameData -> Route.HomeParams -> Html msg
view model gameData params =
    case ( model.graph, model.error ) of
        ( Nothing, Just err ) ->
            div [] [ text <| Debug.toString err ]

        ( Nothing, Nothing ) ->
            div [] [ text "???no graph???" ]

        ( Just { game, char }, _ ) ->
            case zipPerks char params game of
                Err err ->
                    div [] [ text err ]

                Ok perks ->
                    perks
                        |> List.map
                            (\perk ->
                                let
                                    level : Int
                                    level =
                                        Dict.get perk.key model.transcendPerks |> Maybe.withDefault 0
                                in
                                li []
                                    [ div [] [ b [] [ text perk.data.name ] ]
                                    , div [] [ text perk.data.description ]

                                    -- , div [] [ text <| Debug.toString perk.stats.costFunction ]
                                    , div []
                                        (case perk.stats.trait of
                                            Nothing ->
                                                []

                                            Just t ->
                                                [ text "trait: ", text t ]
                                        )
                                    , div [] [ text "Level: ", text <| String.fromInt level ]

                                    -- , div [] [ text <| Debug.toString perk ]
                                    ]
                            )
                        |> ul []
