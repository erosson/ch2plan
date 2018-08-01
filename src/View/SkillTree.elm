module View.SkillTree exposing (view)

import Dict as Dict exposing (Dict)
import Set as Set exposing (Set)
import Html as H
import Html.Attributes as A
import Html.Events as E
import Maybe.Extra
import Json.Decode as Decode
import Model as M
import Route
import GameData as G
import GameData.Stats as GS exposing (Stat(..))
import View.Stats
import View.Graph


view : List (H.Html M.Msg) -> M.Model -> M.HomeModel -> H.Html M.Msg
view header model home =
    if model.features.fullscreen then
        viewFullscreenTree header model home
    else
        viewOldTree header model home


viewOldTree : List (H.Html M.Msg) -> M.Model -> M.HomeModel -> H.Html M.Msg
viewOldTree header ({ features, lastUpdatedVersion } as model) home =
    H.div [] <|
        header
            ++ viewSelectSave features
            ++ [ H.h4 [] [ H.text <| home.graph.char.flavorName ++ ", " ++ home.graph.char.flavorClass ]
               , H.p [] [ H.text <| home.graph.char.flavor ]
               , viewVersionNav home.graph.game home.params
               , viewSearch home
               , H.div [ A.style [ ( "width", "1000px" ), ( "height", "1000px" ) ] ]
                    [ View.Graph.view { width = 1000, height = 1000 } home features ]
               , viewSearch home
               , H.p [] [ H.a [ Route.href <| Route.Stats home.params ] [ H.text "Statistics:" ] ]
               , View.Stats.viewStatsSummary <| GS.statTable <| M.statsSummary home.graph
               , H.p [] [ H.a [ Route.href <| Route.Stats home.params ] [ H.text <| toString (Set.size home.graph.selected) ++ " skill points" ] ]
               ]


viewFullscreenTree : List (H.Html M.Msg) -> M.Model -> M.HomeModel -> H.Html M.Msg
viewFullscreenTree header ({ windowSize, features } as model) home =
    H.div [ A.class "skill-tree-main" ]
        [ View.Graph.view windowSize home features
        , if home.sidebarOpen then
            H.div [ A.class "sidebar" ]
                ([ H.button [ A.class "sidebar-hide", A.title "hide", E.onClick M.ToggleSidebar ] [ H.text "<<" ] ]
                    ++ header
                    ++ viewSelectSave features
                    ++ [ H.h4 [] [ H.text <| home.graph.char.flavorName ++ ", " ++ home.graph.char.flavorClass ]
                       , H.p [] [ H.text <| home.graph.char.flavor ]
                       , viewVersionNav home.graph.game home.params
                       , viewSearch home
                       , H.p [] [ H.a [ Route.href <| Route.Stats home.params ] [ H.text "Statistics:" ] ]
                       , View.Stats.viewStatsSummary <| GS.statTable <| M.statsSummary home.graph
                       , H.p [] [ H.a [ Route.href <| Route.Stats home.params ] [ H.text <| toString (Set.size home.graph.selected) ++ " skill points" ] ]
                       ]
                )
          else
            H.button [ A.class "sidebar-show", A.title "show", E.onClick M.ToggleSidebar ] [ H.text ">>" ]
        ]


ver =
    { live = "0.06-beta"
    , ptr = ""
    }


viewVersionNav : G.GameVersionData -> Route.HomeParams -> H.Html msg
viewVersionNav g q =
    if ver.ptr == "" then
        H.div [] []
    else
        H.div []
            [ H.text <| "Your game version: " ++ g.versionSlug ++ ". "
            , if g.versionSlug == ver.live then
                H.a [ Route.href <| Route.Home { q | version = ver.ptr } ] [ H.text <| "Use PTR: " ++ ver.ptr ]
              else
                H.a [ Route.href <| Route.Home { q | version = ver.live } ] [ H.text <| "Use live: " ++ ver.live ]
            ]


viewSelectSave : Route.Features -> List (H.Html M.Msg)
viewSelectSave features =
    if features.saveImport then
        [ H.div []
            [ H.text "Import build from game save : "
            , H.input
                [ A.type_ "file"
                , A.id inputSaveSelectId
                , E.on "change"
                    (Decode.succeed <| M.SaveFileSelected inputSaveSelectId)
                ]
                []
            ]
        ]
    else
        []


inputSaveSelectId =
    "inputSaveSelect"


viewSearch : M.HomeModel -> H.Html M.Msg
viewSearch home =
    H.div []
        [ H.text "Highlight: "
        , H.input [ A.type_ "text", A.value <| Maybe.withDefault "" home.searchString, E.onInput M.SearchInput ] []
        ]


viewNodeType : String -> G.NodeType -> H.Html msg
viewNodeType key nodetype =
    H.text <| key ++ ": " ++ toString nodetype


dumpModel : M.Model -> H.Html msg
dumpModel =
    H.text << toString
