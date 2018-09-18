module View exposing (view)

import Browser
import Dict as Dict exposing (Dict)
import GameData as G
import Html as H
import Html.Attributes as A
import Html.Events as E
import Model as M
import Route as Route exposing (Route)
import View.Changelog
import View.SkillTree
import View.Spreadsheet
import View.Stats


view : M.Model -> Browser.Document M.Msg
view model =
    { title = "Clicker Heroes 2 Skill Tree Planner", body = [ viewBody model ] }


viewBody : M.Model -> H.Html M.Msg
viewBody model =
    let
        header =
            [ H.h2 [] [ H.text "Clicker Heroes 2 Skill Tree Planner" ]
            , H.nav []
                (viewCharacterNav (gameVersion model)
                    ++ [ viewNavEntry "Changelog" Route.Changelog
                       , H.a [ A.href "https://github.com/erosson/ch2plan", A.target "_blank" ] [ H.text "Source code" ]
                       ]
                )
            ]
    in
    case model.route of
        Route.Home home ->
            case model.graph of
                Nothing ->
                    H.div [] (header ++ [ H.text "404" ])

                Just graph ->
                    View.SkillTree.view header model graph

        Route.NotFound ->
            H.div [] (header ++ [ H.text "404" ])

        Route.Changelog ->
            H.div [] (header ++ [ View.Changelog.view model.changelog ])

        Route.LegacyHome _ ->
            H.div [] [ H.text "loading..." ]

        Route.Root _ ->
            H.div [] [ H.text "loading..." ]

        Route.Stats params ->
            H.div [] (header ++ [ View.Stats.view model params ])

        Route.StatsTSV params ->
            View.Spreadsheet.view model params


gameVersion : M.Model -> G.GameVersionData
gameVersion model =
    model.graph |> Maybe.map .game |> Maybe.withDefault (G.latestVersion model.gameData)


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
