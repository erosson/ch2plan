module View exposing (view)

import Dict as Dict exposing (Dict)
import Html as H
import Html.Attributes as A
import Html.Events as E
import GameData as G
import Model as M
import Route as Route exposing (Route)
import View.SkillTree
import View.Changelog
import View.Stats


view : M.Model -> H.Html M.Msg
view model =
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
            M.Home home ->
                View.SkillTree.view header model home

            M.HomeError q ->
                H.div [] (header ++ [ H.text "404" ])

            M.StatelessRoute Route.NotFound ->
                H.div [] (header ++ [ H.text "404" ])

            M.StatelessRoute Route.Changelog ->
                H.div [] (header ++ [ View.Changelog.view model.changelog ])

            M.StatelessRoute (Route.Home _) ->
                Debug.crash "home is not stateless. How did this happen?"

            M.StatelessRoute (Route.LegacyHome _) ->
                H.div [] [ H.text "loading..." ]

            M.StatelessRoute (Route.Root _) ->
                H.div [] [ H.text "loading..." ]

            M.StatelessRoute (Route.Stats params) ->
                H.div [] (header ++ [ View.Stats.view model params ])


gameVersion : M.Model -> G.GameVersionData
gameVersion m =
    case m.route of
        M.Home { params } ->
            Dict.get params.version m.gameData.byVersion
                |> Maybe.withDefault (G.latestVersion m.gameData)

        _ ->
            G.latestVersion m.gameData


viewCharacterNav : G.GameVersionData -> List (H.Html msg)
viewCharacterNav g =
    g.heroes |> Dict.toList |> List.map (uncurry <| viewCharacterNavEntry g.versionSlug)


viewCharacterNavEntry : String -> String -> G.Character -> H.Html msg
viewCharacterNavEntry version key char =
    let
        q =
            Route.delegacy version Route.homeParams0
    in
        viewNavEntry char.flavorClass (Route.Home { q | hero = key })


viewNavEntry : String -> Route -> H.Html msg
viewNavEntry text route =
    H.a [ Route.href route ] [ H.text text ]
