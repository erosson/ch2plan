module View.SkillTree exposing (view)

{-| Html parts of the SkillTree page

Don't import Svg!

-}

import Dict exposing (Dict)
import GameData exposing (GameData)
import GameData.Stats as Stats exposing (Stat(..))
import Html as H exposing (..)
import Html.Attributes as A exposing (..)
import Html.Events as E exposing (..)
import Json.Decode as Decode
import Maybe.Extra
import Model exposing (Model, Msg)
import Model.Graph as Graph exposing (GraphModel)
import Route
import Set exposing (Set)
import View.SkillTreeGraph
import View.Stats


ver =
    { live = Route.liveVersion
    , ptr = ""
    }


view : List (Html Msg) -> Model -> GraphModel -> Route.HomeParams -> Html Msg
view header model graph params =
    let
        ethItemCount =
            model.etherealItemInventory |> Maybe.Extra.unwrap 0 Dict.size
    in
    div [ A.class "skill-tree-main" ]
        [ viewGraph model graph
        , if model.sidebarOpen then
            div [ A.class "sidebar" ]
                ([ button [ A.class "sidebar-hide", A.title "hide", E.onClick Model.ToggleSidebar ] [ text "<<" ] ]
                    ++ header
                    ++ [ viewSelectSave ]
                    ++ viewImportExport params
                    ++ viewError model.error
                    ++ [ h4 [] [ text <| graph.char.flavorName ++ ", " ++ graph.char.flavorClass ]
                       , p [] [ text <| graph.char.flavor ]
                       , viewVersionNav graph.game params
                       , viewSearch model params.version
                       , p [] [ a [ Route.href <| Route.EthItems ] [ text <| String.fromInt ethItemCount, text " ethereal items" ] ]
                       , p [] <|
                            if model.features.transcendNodes then
                                [ a [ Route.href <| Route.Transcend params ] [ text "Transcension Perks" ] ]

                            else
                                []
                       , p [] [ a [ Route.href <| Route.Stats params ] [ text "Statistics:" ] ]
                       , View.Stats.viewStatsSummary graph.char <| Stats.statTable <| Model.statsSummary model graph
                       , p [] [ a [ Route.href <| Route.Stats params ] [ text <| String.fromInt (Set.size graph.selected.set) ++ " skill points" ] ]
                       , p [] [ a [ Route.href <| Route.StatsTSV params ] [ text "Spreadsheet format" ] ]
                       ]
                )

          else
            button [ A.class "sidebar-show", A.title "show", E.onClick Model.ToggleSidebar ] [ text ">>" ]
        ]


viewImportExport : Route.HomeParams -> List (Html Msg)
viewImportExport params =
    [ div []
        [ text "In-game planner import/export:"
        , input [ onInput Model.TextImport, value <| Maybe.withDefault "" params.build ] []
        , div [] [ small [] [ text "copy this to export, or paste here to import" ] ]
        ]
    ]


viewGraph : Model -> GraphModel -> Html Msg
viewGraph model graph =
    -- svg-container is for tooltip positioning. It must be exactly the same size as the svg itself.
    div [ class "svg-container" ]
        (View.SkillTreeGraph.view model graph
            :: Maybe.Extra.unwrap []
                (List.singleton << viewTooltip model graph)
                (Model.visibleTooltip model |> Maybe.andThen ((\b a -> Dict.get a b) graph.char.graph.nodes))
        )


viewVersionNav : GameData.GameVersionData -> Route.HomeParams -> Html msg
viewVersionNav g q =
    div []
        [ text <| "Your game version: " ++ g.versionSlug ++ ". "
        , if g.versionSlug == ver.live then
            if ver.ptr /= "" then
                a [ Route.href <| Route.Home { q | version = ver.ptr } ] [ text <| "Use PTR: " ++ ver.ptr ]

            else
                text ""

          else
            a [ Route.href <| Route.Home { q | version = ver.live } ] [ text <| "Use live: " ++ ver.live ]
        ]


viewSelectSave : Html Msg
viewSelectSave =
    div []
        [ text "Import build from game save : "
        , input
            [ A.type_ "file"
            , A.id inputSaveSelectId
            , E.on "change"
                (Decode.succeed <| Model.SaveFileSelected inputSaveSelectId)
            ]
            []
        , p [ A.class "saveSelectHint" ]
            [ text "Hint: your save files are probably located in"
            , br [] []
            , text "C:\\Users\\$USERNAME\\AppData\\Roaming\\ClickerHeroes2\\Local Store\\saves"
            ]
        ]


inputSaveSelectId =
    "inputSaveSelect"


viewError : Maybe Model.Error -> List (Html Msg)
viewError error =
    [ p [ A.class "error" ]
        (case error of
            Just error_ ->
                [ text <|
                    case error_ of
                        Model.SearchRegexError ->
                            "Search error"

                        Model.SaveImportError err ->
                            "Couldn't load that saved game: " ++ err

                        Model.BuildNodesError err ->
                            "Invalid build: " ++ err

                        Model.GraphError err ->
                            "Can't graph that: " ++ err
                ]

            Nothing ->
                []
        )
    ]


viewSearch : Model -> String -> Html Msg
viewSearch model version =
    div []
        [ a [ A.href "javascript:void", E.onClick <| Model.SearchHelp <| not model.searchHelp ] [ text "Search" ]
        , text ": "
        , input [ A.type_ "text", A.value <| Maybe.withDefault "" model.searchString, E.onInput Model.SearchInput ] []
        , div []
            (if model.searchHelp then
                [ p []
                    [ text "Use "
                    , a [ A.href "https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_Expressions#Writing_a_regular_expression_pattern" ]
                        [ text "regular expressions" ]
                    , text " for advanced searches."
                    ]
                , p []
                    [ text "To highlight searches with different colors, (parenthesize) up to 6 groups, separated by |vertical bars|. For example, try a search for:"
                    , div []
                        [ code []
                            [ a [ A.target "_blank", A.href <| "#/g/" ++ version ++ "/helpfulAdventurer?q=(big)|(huge)|(multiclick)|(energize)" ]
                                [ text "(big)|(huge)|(multiclick)|(energize)" ]
                            ]
                        ]
                    ]
                ]

             else
                []
            )
        ]


viewTooltip : Model -> GraphModel -> GameData.Node -> Html Msg
viewTooltip model graph node =
    -- no css-scaling here - tooltips don't scale with zoom.
    -- no svg here - svg can't word-wrap, and <foreignObject> has screwy browser support.
    --
    -- svg has no viewbox and the html container size == the svg size,
    -- so coordinates in both should match.
    let
        ( win, panX, panY ) =
            View.SkillTreeGraph.panOffsets model graph

        ( w, h ) =
            ( toFloat win.width, toFloat win.height )

        zoom =
            Model.zoom { model | windowSize = win } graph

        ( x, y ) =
            ( (toFloat node.x + panX) * zoom, (toFloat node.y + panY) * zoom )

        sidebarOffset =
            if model.sidebarOpen then
                View.SkillTreeGraph.sidebarWidth

            else
                0

        style_ =
            [ if x > sidebarOffset + w / 2 then
                ( "right", sidebarOffset + w - x )

              else
                ( "left", x )
            , if y > h / 2 then
                ( "bottom", h - y )

              else
                ( "top", y )
            ]
                |> List.map (Tuple.mapSecond <| \n -> String.fromFloat n ++ "px")
                |> List.map (\( k, v ) -> style k v)
    in
    div ([ class "tooltip" ] ++ style_)
        [ b [] [ text node.val.name ]
        , p [] [ text <| GameData.tooltip node.val "" ]

        -- , p [] [ text <| Debug.toString node.val.stats ]
        , p [ class "flavor" ] [ text <| Maybe.withDefault "" node.val.flavorText ]
        , p [ class "flammable" ]
            (if node.val.flammable then
                [ text "Flammable: The effects of this node will be lost when you choose to Ascend or Transcend" ]

             else
                []
            )
        , div [] <|
            let
                level =
                    model.transcendNodes |> Dict.get node.id |> Maybe.withDefault 1
            in
            if model.features.transcendNodes then
                [ div [] <|
                    if level > 1 then
                        [ text "Level ", text <| String.fromInt level ]

                    else
                        -- `&nbsp;` https://twitter.com/rtfeldman/status/767263564214120448?lang=en
                        -- this ensures the buttons don't move between levels 1 and 2
                        [ text "\u{00A0}" ]
                , div [] <|
                    if model.tooltip == Just ( node.id, Model.Longpressing ) || model.tooltip == Just ( node.id, Model.CtrlClicking ) then
                        if node.val.flammable then
                            [ button [ disabled True ] [ text "Cannot Upgrade" ] ]

                        else
                            [ button
                                [ onClick <| Model.TranscendNodeUpgrade node.id
                                ]
                                [ text "Upgrade" ]
                            , button
                                [ onClick <| Model.TranscendNodeDowngrade node.id
                                , disabled <| level <= 1
                                ]
                                [ text "Downgrade" ]
                            ]

                    else
                        []
                ]

            else
                []
        ]
