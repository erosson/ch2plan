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
import GameData.Stats as GS
import ViewGraph


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
            ++ [ H.h4 [] [ H.text <| home.graph.char.flavorName ++ ", " ++ home.graph.char.flavorClass ]
               , H.p [] [ H.text <| home.graph.char.flavor ]
               , viewSearch home
               , H.div [ A.style [ ( "width", "1000px" ), ( "height", "1000px" ) ] ]
                    [ ViewGraph.view { width = 1000, height = 1000 } home features ]
               , viewSearch home
               , viewStatsSummary <| M.statsSummary home
               , viewSummary <| M.nodeSummary home
               , H.p [] [ H.text <| "Last updated: " ++ lastUpdatedVersion ]
               ]


viewFullscreenTree : List (H.Html M.Msg) -> M.Model -> M.HomeModel -> H.Html M.Msg
viewFullscreenTree header ({ windowSize, features } as model) home =
    H.div [ A.class "skill-tree-main" ]
        [ ViewGraph.view windowSize home features
        , if home.sidebarOpen then
            H.div [ A.class "sidebar" ]
                ([ H.button [ A.class "sidebar-hide", A.title "hide", E.onClick M.ToggleSidebar ] [ H.text "<<" ] ]
                    ++ header
                    ++ [ H.h4 [] [ H.text <| home.graph.char.flavorName ++ ", " ++ home.graph.char.flavorClass ]
                       , H.p [] [ H.text <| home.graph.char.flavor ]
                       , viewSearch home
                       , viewStatsSummary <| M.statsSummary home
                       , viewSummary <| M.nodeSummary home
                       ]
                )
          else
            H.button [ A.class "sidebar-show", A.title "show", E.onClick M.ToggleSidebar ] [ H.text ">>" ]
        ]


viewStatsSummary : List GS.StatTotal -> H.Html msg
viewStatsSummary stats =
    H.div [ A.class "stats-summary" ]
        [ H.p [] [ H.text "Stats summary:" ]
        , H.table [] (List.map viewStatSummary stats |> Maybe.Extra.values)
        ]


pct : Float -> String
pct f =
    (f * 100 |> floor |> toString) ++ "%"


pct0 f =
    pct <| f - 1


negPct f =
    if f == 1 then
        "-0%"
    else
        pct0 f


int =
    toString << floor


viewStatSummary : GS.StatTotal -> Maybe (H.Html msg)
viewStatSummary { stat, level, val } =
    let
        body =
            case stat of
                GS.STAT_GOLD ->
                    Just ( "Gold", "×" ++ pct val )

                GS.STAT_HASTE ->
                    Just ( "Haste", "×" ++ pct val )

                GS.STAT_CRIT_CHANCE ->
                    Just ( "Critical Chance", pct val )

                GS.STAT_CRIT_DAMAGE ->
                    Just ( "Critical Damage Multiplier", "×" ++ pct val )

                GS.STAT_TOTAL_ENERGY ->
                    Just ( "Maximum Energy", int val )

                GS.STAT_TOTAL_MANA ->
                    Just ( "Maximum Mana", int val )

                GS.STAT_BONUS_GOLD_CHANCE ->
                    Just ( "Bonus ×10 Gold Chance", pct val )

                GS.STAT_ITEM_COST_REDUCTION ->
                    Just ( "Item Cost Reduction", negPct val )

                GS.STAT_CLICK_DAMAGE ->
                    Just ( "Click Damage Multiplier", "×" ++ pct val )

                GS.STAT_MANA_REGEN ->
                    Just ( "Mana Regeneration", "×" ++ pct val )

                GS.STAT_CLICKABLE_CHANCE ->
                    Just ( "Clickable Find Chance", pct val )

                GS.STAT_TREASURE_CHEST_CHANCE ->
                    Just ( "Treasure Chest Chance", pct val )

                GS.STAT_TREASURE_CHEST_GOLD ->
                    Just ( "Treasure Chest Gold", "×" ++ pct val )

                GS.STAT_CLICKABLE_GOLD ->
                    Just ( "Clickable Gold Multiplier", "×" ++ pct val )

                GS.STAT_AUTOMATOR_SPEED ->
                    Just ( "Automator Speed", "×" ++ pct val )

                GS.STAT_ITEM_WEAPON_DAMAGE ->
                    Just ( "Weapon Damage", "×" ++ pct val )

                GS.STAT_ITEM_HEAD_DAMAGE ->
                    Just ( "Helmet Damage", "×" ++ pct val )

                GS.STAT_ITEM_CHEST_DAMAGE ->
                    Just ( "Chest Damage", "×" ++ pct val )

                GS.STAT_ITEM_RING_DAMAGE ->
                    Just ( "Ring Damage", "×" ++ pct val )

                GS.STAT_ITEM_LEGS_DAMAGE ->
                    Just ( "Pants Damage", "×" ++ pct val )

                GS.STAT_ITEM_HANDS_DAMAGE ->
                    Just ( "Gloves Damage", "×" ++ pct val )

                GS.STAT_ITEM_FEET_DAMAGE ->
                    Just ( "Boots Damage", "×" ++ pct val )

                GS.STAT_ITEM_BACK_DAMAGE ->
                    Just ( "Cape Damage", "×" ++ pct val )

                GS.ExtraMulticlicks ->
                    if level > 0 then
                        Just ( "Multiclick Clicks (no flurry/frenzy yet)", int val )
                    else
                        Nothing

                GS.MulticlickCost ->
                    if level > 0 then
                        Just ( "Multiclick Energy Cost", int val )
                    else
                        Nothing

                GS.BigClicksStacks ->
                    if level > 0 then
                        Just ( "Big Clicks Stacks", int val )
                    else
                        Nothing

                GS.BigClicksDamage ->
                    if level > 0 then
                        Just ( "Big Clicks Damage Multiplier", pct val )
                    else
                        Nothing

                GS.HugeClickDamage ->
                    if level > 0 then
                        Just ( "Huge Click Damage Multiplier", pct val )
                    else
                        Nothing

                GS.ManaCritDamage ->
                    if level > 0 then
                        Just ( "Mana Crit Damage Multiplier", pct val )
                    else
                        Nothing

                _ ->
                    -- Just ( toString ( stat, level ), toString val )
                    Nothing
    in
        Maybe.map
            (\( label, value ) ->
                H.tr
                    [ A.class <| "level-" ++ statLevelTier level
                    , A.title <| "Level " ++ toString level
                    ]
                    [ H.td [] [ H.text <| label ++ ": " ]
                    , H.td [ A.class "stat-value" ] [ H.text value ]

                    -- , H.td [ A.class "stat-level" ] [ H.text <| "Level " ++ toString level ]
                    ]
            )
            body


statLevelTier : Int -> String
statLevelTier level =
    if level > 7 then
        "high"
    else if level > 3 then
        "mid"
    else
        "low"


viewSearch : M.HomeModel -> H.Html M.Msg
viewSearch home =
    H.div []
        [ H.div [] [ H.text <| toString (Set.size home.graph.selected) ++ " points spent." ]
        , H.div []
            [ H.text "Highlight: "
            , H.input [ A.type_ "text", A.value <| Maybe.withDefault "" home.searchString, E.onInput M.SearchInput ] []
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
    H.li [ A.class <| ViewGraph.nodeQualityClass nodeType.quality ]
        [ H.div [ A.class "icon" ]
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
