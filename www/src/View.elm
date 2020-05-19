module View exposing (view)

import Browser
import Dict as Dict exposing (Dict)
import GameData as G
import Html as H
import Html.Attributes as A
import Html.Events as E
import Json.Decode as D
import Maybe.Extra
import Model as M
import Route as Route exposing (Route)
import View.Changelog
import View.EthItems
import View.SkillTree
import View.Spreadsheet
import View.Stats


view : M.Model -> Browser.Document M.Msg
view model =
    { title = "Clicker Heroes 2 Skill Tree Planner", body = [ viewBody model ] }


viewBody : M.Model -> H.Html M.Msg
viewBody model =
    case model.gameData of
        Err err ->
            H.div [] [ H.text "error parsing gameData: ", H.pre [] [ H.text <| D.errorToString err ] ]

        Ok gameData ->
            let
                header =
                    [ H.h2 [] [ H.text "Clicker Heroes 2 Skill Tree Planner" ]
                    , H.nav []
                        (Maybe.Extra.unwrap [] viewCharacterNav (gameVersion model gameData)
                            ++ [ viewNavEntry "Changelog" Route.Changelog
                               , H.a [ A.href "https://github.com/erosson/ch2plan", A.target "_blank" ] [ H.text "Source code" ]
                               ]
                        )
                    ]
            in
            case model.route of
                Nothing ->
                    H.div [] (header ++ [ H.text "404" ])

                Just route ->
                    case route of
                        Route.Redirect _ ->
                            H.div [] [ H.text "loading..." ]

                        Route.Home home ->
                            case model.graph of
                                Nothing ->
                                    H.div [] (header ++ [ H.text "404" ])

                                Just graph ->
                                    View.SkillTree.view header model graph home

                        Route.Changelog ->
                            H.div [] (header ++ [ View.Changelog.view model.changelog ])

                        Route.Stats params ->
                            H.div [] (header ++ [ View.Stats.view model gameData params ])

                        Route.StatsTSV params ->
                            View.Spreadsheet.view model gameData params

                        Route.EthItems ->
                            H.div [] (header ++ [ View.EthItems.view model ])


gameVersion : M.Model -> G.GameData -> Maybe G.GameVersionData
gameVersion model gameData =
    model.graph |> Maybe.map .game |> Maybe.Extra.orElse (G.latestVersion gameData)


viewCharacterNav : G.GameVersionData -> List (H.Html msg)
viewCharacterNav g =
    g.heroes |> Dict.toList |> List.map ((\f ( a, b ) -> f a b) <| viewCharacterNavEntry g.versionSlug)


viewCharacterNavEntry : String -> String -> G.Character -> H.Html msg
viewCharacterNavEntry version key char =
    let
        q =
            Route.defaultParams version
    in
    viewNavEntry char.flavorClass (Route.Home { q | hero = key })


viewNavEntry : String -> Route -> H.Html msg
viewNavEntry text route =
    H.a [ Route.href route ] [ H.text text ]
