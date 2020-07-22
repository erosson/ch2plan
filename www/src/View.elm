module View exposing (view)

import Browser
import Dict exposing (Dict)
import GameData exposing (GameData)
import Html as H exposing (..)
import Html.Attributes as A exposing (..)
import Html.Events as E exposing (..)
import Json.Decode as D
import Maybe.Extra
import Model exposing (Model, Msg)
import Route exposing (Route)
import View.Changelog
import View.EthItems
import View.Runecorder
import View.SkillTree
import View.Spreadsheet
import View.Stats
import View.Transcend


view : Model -> Browser.Document Msg
view model =
    { title = "Clicker Heroes 2 Skill Tree Planner", body = [ viewBody model ] }


viewBody : Model -> Html Msg
viewBody model =
    case model.gameData of
        Err err ->
            div [] [ text "error parsing gameData: ", pre [] [ text <| D.errorToString err ] ]

        Ok gameData ->
            let
                header =
                    [ h2 [] [ text "Clicker Heroes 2 Skill Tree Planner" ]
                    , nav []
                        (Maybe.Extra.unwrap [] viewCharacterNav (gameVersion model gameData)
                            ++ [ viewNavEntry "Changelog" Route.Changelog
                               , a [ href "https://github.com/erosson/ch2plan", target "_blank" ] [ text "Source code" ]
                               ]
                        )
                    ]
            in
            case model.route of
                Nothing ->
                    div [] (header ++ [ text "404" ])

                Just route ->
                    case route of
                        Route.Redirect _ ->
                            div [] [ text "loading..." ]

                        Route.Home home ->
                            case model.graph of
                                Nothing ->
                                    div [] (header ++ [ text "404" ])

                                Just graph ->
                                    View.SkillTree.view header model graph home

                        Route.Stats params ->
                            div [] (header ++ [ View.Stats.view model gameData params ])

                        Route.StatsTSV params ->
                            View.Spreadsheet.view model gameData params

                        Route.Transcend params ->
                            View.Transcend.view model gameData params

                        Route.EthItems ->
                            div [] (header ++ [ View.EthItems.view model ])

                        Route.Changelog ->
                            div [] (header ++ [ View.Changelog.view model.changelog ])

                        Route.Runecorder _ ->
                            div [] (header ++ [ View.Runecorder.view model gameData ])


gameVersion : Model -> GameData -> Maybe GameData.GameVersionData
gameVersion model gameData =
    model.graph |> Maybe.map .game |> Maybe.Extra.orElse (GameData.latestVersion gameData)


viewCharacterNav : GameData.GameVersionData -> List (Html msg)
viewCharacterNav g =
    g.heroes |> Dict.toList |> List.map ((\f ( a, b ) -> f a b) <| viewCharacterNavEntry g.versionSlug)


viewCharacterNavEntry : String -> String -> GameData.Character -> Html msg
viewCharacterNavEntry version key char =
    let
        q =
            Route.defaultParams version
    in
    viewNavEntry char.flavorClass (Route.Home { q | hero = key })


viewNavEntry : String -> Route -> Html msg
viewNavEntry txt route =
    a [ Route.href route ] [ text txt ]
