module View exposing (view)

import Html as H
import Html.Attributes as A
import Html.Events as E
import Model as M
import Route as Route exposing (Route)
import ViewSkillTree
import ViewChangelog


view : M.Model -> H.Html M.Msg
view model =
    H.div []
        [ H.h2 [] [ H.text "Clicker Heroes 2 Skill Tree Planner" ]
        , H.nav []
            [ viewNavEntry "Skill Tree" (Route.Home Route.homeParams0)
            , viewNavEntry "Changelog" Route.Changelog
            , H.a [ A.href "https://github.com/erosson/ch2plan", A.target "_blank" ] [ H.text "Source code" ]
            ]
        , case model.route of
            Route.Home _ ->
                ViewSkillTree.view model

            Route.Changelog ->
                ViewChangelog.view model.changelog
        ]


viewNavEntry : String -> Route -> H.Html msg
viewNavEntry text route =
    H.a [ Route.href route ] [ H.text text ]
