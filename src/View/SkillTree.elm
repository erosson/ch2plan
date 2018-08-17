module View.SkillTree exposing (view)

import Dict as Dict exposing (Dict)
import Set as Set exposing (Set)
import Html as H
import Html.Attributes as A
import Html.Events as E
import Maybe.Extra
import Json.Decode as Decode
import Model as M
import Model.Graph as MG
import Route
import GameData as G
import GameData.Stats as GS exposing (Stat(..))
import View.Stats
import View.Graph


view : List (H.Html M.Msg) -> M.Model -> MG.GraphModel -> H.Html M.Msg
view header model graph =
    let
        params =
            case Route.params model.route of
                Nothing ->
                    Debug.crash "wtf"

                Just params ->
                    params
    in
        H.div [ A.class "skill-tree-main" ]
            [ View.Graph.view model graph
            , if model.sidebarOpen then
                H.div [ A.class "sidebar" ]
                    ([ H.button [ A.class "sidebar-hide", A.title "hide", E.onClick M.ToggleSidebar ] [ H.text "<<" ] ]
                        ++ header
                        ++ [ viewSelectSave ]
                        ++ viewError model.error
                        ++ [ H.h4 [] [ H.text <| graph.char.flavorName ++ ", " ++ graph.char.flavorClass ]
                           , H.p [] [ H.text <| graph.char.flavor ]
                           , viewVersionNav graph.game params
                           , viewSearch model
                           , H.p [] [ H.a [ Route.href <| Route.Stats params ] [ H.text "Statistics:" ] ]
                           , View.Stats.viewStatsSummary <| GS.statTable <| M.statsSummary graph
                           , H.p [] [ H.a [ Route.href <| Route.Stats params ] [ H.text <| toString (Set.size graph.selected) ++ " skill points" ] ]
                           , H.p [] [ H.a [ Route.href <| Route.StatsTSV params ] [ H.text "Spreadsheet format" ] ]
                           ]
                    )
              else
                H.button [ A.class "sidebar-show", A.title "show", E.onClick M.ToggleSidebar ] [ H.text ">>" ]
            ]


ver =
    { live = "0.06-beta"
    , ptr = "0.07-(2)-beta-PTR"
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


viewSelectSave : H.Html M.Msg
viewSelectSave =
    H.div []
        [ H.text "Import build from game save : "
        , H.input
            [ A.type_ "file"
            , A.id inputSaveSelectId
            , E.on "change"
                (Decode.succeed <| M.SaveFileSelected inputSaveSelectId)
            ]
            []
        , H.p [ A.class "saveSelectHint" ]
            [ H.text "Hint: your save files are probably located in"
            , H.br [] []
            , H.text "C:\\Users\\$USERNAME\\AppData\\Roaming\\ClickerHeroes2\\Local Store\\saves"
            ]
        ]


inputSaveSelectId =
    "inputSaveSelect"


viewError : Maybe M.Error -> List (H.Html M.Msg)
viewError error =
    [ H.p [ A.class "error" ]
        (case error of
            Just error ->
                [ H.text <|
                    case error of
                        M.SearchRegexError err ->
                            "Search error: " ++ err

                        M.SaveImportError _ ->
                            -- the string here is only meaningful to devs
                            "Couldn't load that saved game."

                        M.BuildNodesError err ->
                            "Invalid build: " ++ err

                        M.GraphError err ->
                            "Can't graph that: " ++ err
                ]

            Nothing ->
                []
        )
    ]


viewSearch : M.Model -> H.Html M.Msg
viewSearch model =
    H.div []
        [ H.text "Highlight: "
        , H.input [ A.type_ "text", A.value <| Maybe.withDefault "" model.searchString, E.onInput M.SearchInput ] []
        ]


viewNodeType : String -> G.NodeType -> H.Html msg
viewNodeType key nodetype =
    H.text <| key ++ ": " ++ toString nodetype


dumpModel : M.Model -> H.Html msg
dumpModel =
    H.text << toString
