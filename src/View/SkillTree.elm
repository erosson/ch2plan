module View.SkillTree exposing (view)

import Dict as Dict exposing (Dict)
import GameData as G
import GameData.Stats as GS exposing (Stat(..))
import Html as H
import Html.Attributes as A
import Html.Events as E
import Json.Decode as Decode
import Maybe.Extra
import Model as M
import Model.Graph as MG
import Route
import Set as Set exposing (Set)
import View.Graph
import View.Stats


view : List (H.Html M.Msg) -> M.Model -> MG.GraphModel -> H.Html M.Msg
view header model graph =
    let
        params =
            case model.route |> Maybe.andThen Route.params of
                Nothing ->
                    Debug.todo "viewing skilltree without a skilltree url?"

                Just params_ ->
                    params_

        ethItemCount =
            model.etherealItemInventory |> Maybe.Extra.unwrap 0 Dict.size
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
                       , viewSearch model params.version
                       , H.p [] [ H.a [ Route.href <| Route.EthItems ] [ H.text <| String.fromInt ethItemCount, H.text " ethereal items" ] ]
                       , H.p [] [ H.a [ Route.href <| Route.Stats params ] [ H.text "Statistics:" ] ]
                       , View.Stats.viewStatsSummary <| GS.statTable <| M.statsSummary graph
                       , H.p [] [ H.a [ Route.href <| Route.Stats params ] [ H.text <| String.fromInt (Set.size graph.selected) ++ " skill points" ] ]
                       , H.p [] [ H.a [ Route.href <| Route.StatsTSV params ] [ H.text "Spreadsheet format" ] ]
                       ]
                )

          else
            H.button [ A.class "sidebar-show", A.title "show", E.onClick M.ToggleSidebar ] [ H.text ">>" ]
        ]


ver =
    { live = Route.liveVersion
    , ptr = ""
    }


viewVersionNav : G.GameVersionData -> Route.HomeParams -> H.Html msg
viewVersionNav g q =
    H.div []
        [ H.text <| "Your game version: " ++ g.versionSlug ++ ". "
        , if g.versionSlug == ver.live then
            if ver.ptr /= "" then
                H.a [ Route.href <| Route.Home { q | version = ver.ptr } ] [ H.text <| "Use PTR: " ++ ver.ptr ]

            else
                H.text ""

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
            Just error_ ->
                [ H.text <|
                    case error_ of
                        M.SearchRegexError ->
                            "Search error"

                        M.SaveImportError err ->
                            "Couldn't load that saved game: " ++ err

                        M.BuildNodesError err ->
                            "Invalid build: " ++ err

                        M.GraphError err ->
                            "Can't graph that: " ++ err
                ]

            Nothing ->
                []
        )
    ]


viewSearch : M.Model -> String -> H.Html M.Msg
viewSearch model version =
    H.div []
        [ H.a [ A.href "javascript:void", E.onClick <| M.SearchHelp <| not model.searchHelp ] [ H.text "Search" ]
        , H.text ": "
        , H.input [ A.type_ "text", A.value <| Maybe.withDefault "" model.searchString, E.onInput M.SearchInput ] []
        , H.div []
            (if model.searchHelp then
                [ H.p []
                    [ H.text "Use "
                    , H.a [ A.href "https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_Expressions#Writing_a_regular_expression_pattern" ]
                        [ H.text "regular expressions" ]
                    , H.text " for advanced searches."
                    ]
                , H.p []
                    [ H.text "To highlight searches with different colors, (parenthesize) up to 6 groups, separated by |vertical bars|. For example, try a search for:"
                    , H.div []
                        [ H.code []
                            [ H.a [ A.target "_blank", A.href <| "#/g/" ++ version ++ "/helpfulAdventurer?q=(big)|(huge)|(multiclick)|(energize)" ]
                                [ H.text "(big)|(huge)|(multiclick)|(energize)" ]
                            ]
                        ]
                    ]
                ]

             else
                []
            )
        ]


dumpModel : M.Model -> H.Html msg
dumpModel =
    H.text << Debug.toString
