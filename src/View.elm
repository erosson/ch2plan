module View exposing (view)

import Dict as Dict exposing (Dict)
import Html as H
import Html.Attributes as A
import Html.Events as E
import GameData as G
import Model as M
import Route as Route exposing (Route)
import ViewSkillTree
import ViewChangelog


view : M.Model -> H.Html M.Msg
view model =
    let
        header =
            [ H.h2 [] [ H.text "Clicker Heroes 2 Skill Tree Planner" ]
            , H.nav []
                (viewCharacterNav model.characterData
                    ++ [ viewNavEntry "Changelog" Route.Changelog
                       , H.a [ A.href "https://github.com/erosson/ch2plan", A.target "_blank" ] [ H.text "Source code" ]
                       ]
                )
            ]
    in
        case model.route of
            M.Home home ->
                ViewSkillTree.view header model home

            M.NotFound ->
                H.div [] (header ++ [ H.text "404" ])

            M.HomeError q ->
                H.div [] (header ++ [ H.text "404" ])

            M.Changelog ->
                H.div [] (header ++ [ ViewChangelog.view model.changelog ])


viewCharacterNav : Dict String G.Character -> List (H.Html msg)
viewCharacterNav =
    Dict.toList >> List.map (uncurry viewCharacterNavEntry)


viewCharacterNavEntry : String -> G.Character -> H.Html msg
viewCharacterNavEntry key char =
    let
        q =
            Route.homeParams0
    in
        viewNavEntry char.flavorClass (Route.Home { q | hero = key })


viewNavEntry : String -> Route -> H.Html msg
viewNavEntry text route =
    H.a [ Route.href route ] [ H.text text ]
