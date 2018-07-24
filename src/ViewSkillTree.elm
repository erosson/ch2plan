module ViewSkillTree exposing (view)

import Dict as Dict exposing (Dict)
import Set as Set exposing (Set)
import Html as H
import Html.Attributes as A
import Html.Events as E
import Maybe.Extra
import Model as M
import Route
import GameData as G
import ViewGraph


view : List (H.Html M.Msg) -> M.Model -> M.HomeModel -> H.Html M.Msg
view header model home =
    if model.features.fullscreen then
        viewFullscreenTree header model home
    else
        viewOldTree header model home


viewOldTree : List (H.Html M.Msg) -> M.Model -> M.HomeModel -> H.Html M.Msg
viewOldTree header { characterData, features, lastUpdatedVersion } home =
    H.div [] <|
        header
            ++ [ H.h4 [] [ H.text <| home.char.flavorName ++ ", " ++ home.char.flavorClass ]
               , H.p [] [ H.text <| home.char.flavor ]
               , viewSearch home
               , H.div [ A.style [ ( "width", "1000px" ), ( "height", "1000px" ) ] ]
                    [ ViewGraph.view { width = 1000, height = 1000 } home features ]
               , viewSearch home
               , viewSummary <| M.summary home
               , H.p [] [ H.text <| "Last updated: " ++ lastUpdatedVersion ]
               ]


viewFullscreenTree : List (H.Html M.Msg) -> M.Model -> M.HomeModel -> H.Html M.Msg
viewFullscreenTree header { windowSize, characterData, features, lastUpdatedVersion } home =
    H.div [ A.class "skill-tree-main" ]
        [ ViewGraph.view windowSize home features
        , if home.sidebarOpen then
            H.div [ A.class "sidebar" ]
                ([ H.button [ A.class "sidebar-hide", A.title "hide", E.onClick M.ToggleSidebar ] [ H.text "<<" ] ]
                    ++ header
                    ++ [ H.h4 [] [ H.text <| home.char.flavorName ++ ", " ++ home.char.flavorClass ]
                       , H.p [] [ H.text <| home.char.flavor ]
                       , viewSearch home
                       , viewSummary <| M.summary home
                       ]
                )
          else
            H.button [ A.class "sidebar-show", A.title "show", E.onClick M.ToggleSidebar ] [ H.text ">>" ]
        ]


viewSearch : M.HomeModel -> H.Html M.Msg
viewSearch home =
    H.div []
        [ H.div [] [ H.text <| toString (Set.size home.selected) ++ " points spent." ]
        , H.div []
            [ H.text "Highlight: "
            , H.input [ A.type_ "text", A.value <| Maybe.withDefault "" home.params.search, E.onInput M.SearchInput ] []
            ]
        ]


viewNodeType : String -> G.NodeType -> H.Html msg
viewNodeType key nodetype =
    H.text <| key ++ ": " ++ toString nodetype


viewSummary : List ( Int, G.NodeType ) -> H.Html msg
viewSummary ns =
    H.div [ A.class "summary" ] <|
        if List.length ns == 0 then
            []
        else
            [ H.p [] [ H.text "Build summary: " ]
            , H.ul [] (List.map (uncurry viewSummaryLine) ns)
            ]


viewSummaryLine : Int -> G.NodeType -> H.Html msg
viewSummaryLine count nodeType =
    H.li []
        [ H.div [ A.class <| String.join " " [ "icon", ViewGraph.nodeQualityClass nodeType.quality ] ]
            [ H.img [ A.class "icon-background", A.src <| ViewGraph.nodeBackgroundImage nodeType False False False ] []
            , H.img [ A.class "icon-main", A.src <| ViewGraph.iconUrl nodeType ] []
            ]
        , H.div []
            [ H.text <|
                " "
                    ++ if count /= 1 then
                        toString count ++ "x "
                       else
                        ""
            , H.b [] [ H.text nodeType.name ]
            , H.span [] [ H.text <| Maybe.Extra.unwrap "" ((++) ": ") nodeType.tooltip ]
            ]

        -- , H.div [] [ H.text <| Maybe.withDefault "" nodeType.tooltip ]
        , H.div [ A.class "clear" ] []

        -- , H.text <| toString nodeType
        ]


dumpModel : M.Model -> H.Html msg
dumpModel =
    H.text << toString
