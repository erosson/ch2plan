module ViewSkillTree exposing (view)

import Dict as Dict exposing (Dict)
import Set as Set exposing (Set)
import Time as Time exposing (Time)
import Html as H
import Html.Attributes as A
import Html.Events as E
import Maybe.Extra
import Json.Decode as Decode
import Model as M
import Route
import GameData as G
import GameData.Stats as GS exposing (Stat(..))
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
            ++ viewSelectSave features
            ++ [ H.h4 [] [ H.text <| home.graph.char.flavorName ++ ", " ++ home.graph.char.flavorClass ]
               , H.p [] [ H.text <| home.graph.char.flavor ]
               , viewVersionNav home.graph.game home.params
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
                    ++ viewSelectSave features
                    ++ [ H.h4 [] [ H.text <| home.graph.char.flavorName ++ ", " ++ home.graph.char.flavorClass ]
                       , H.p [] [ H.text <| home.graph.char.flavor ]
                       , viewVersionNav home.graph.game home.params
                       , viewSearch home
                       , viewStatsSummary <| M.statsSummary home
                       , viewSummary <| M.nodeSummary home
                       ]
                )
          else
            H.button [ A.class "sidebar-show", A.title "show", E.onClick M.ToggleSidebar ] [ H.text ">>" ]
        ]


ver =
    { live = "0.052-beta"
    , ptr = "0.06-(2)-beta-PTR"
    }


viewVersionNav : G.GameVersionData -> Route.HomeParams -> H.Html msg
viewVersionNav g q =
    let
        _ =
            Debug.log "viewVersionNav" ( q, g.versionSlug )
    in
        H.div []
            [ H.text <| "Your game version: " ++ g.versionSlug ++ ". "
            , if g.versionSlug == ver.live then
                H.a [ Route.href <| Route.Home { q | version = ver.ptr } ] [ H.text <| "Use PTR: " ++ ver.ptr ]
              else
                H.a [ Route.href <| Route.Home { q | version = ver.live } ] [ H.text <| "Use live: " ++ ver.live ]
            ]


type alias StatsEntrySpec =
    ( String, List GS.Stat, List GS.StatTotal -> Maybe String )


statEntrySpecs : List StatsEntrySpec
statEntrySpecs =
    -- try to match the order of the in-game stats screen here. The order here is
    -- irrelevant to what's displayed, but it makes it easier to keep things matching.
    -- See scripts/ui/StatsSubtab.as
    --
    -- autoattack damage
    -- click damage
    [ ( "Click Damage Multiplier", [ STAT_CLICK_DAMAGE ], entryPct ) -- not actually in the stats screen, only flat click damage
    , ( "Attack Delay", [ STAT_HASTE ], entrySec 600 )

    -- damage multiplier from level
    , ( "Energy from Auto Attacks", [ STAT_MANA_REGEN ], stat1 >> \regen -> Just <| int <| 1 + regen.val ) -- currently a constant
    , ( "Global Cooldown Time", [ STAT_HASTE ], entrySec 2000 ) -- TODO that one keystone for <1 sec
    , ( "Automator Speed", [ STAT_AUTOMATOR_SPEED, STAT_HASTE ], stat2 >> \( auto, haste ) -> Just <| pct <| auto.val * haste.val )
    , ( "Critical Chance", [ STAT_CRIT_CHANCE ], entryPct )
    , ( "Critical Damage Multiplier", [ STAT_CRIT_DAMAGE ], entryPct )
    , ( "Haste", [ STAT_HASTE ], entryPct )
    , ( "Maximum Energy", [ STAT_TOTAL_ENERGY ], entryInt )
    , ( "Maximum Mana", [ STAT_TOTAL_MANA ], entryInt )
    , ( "Mana Regeneration", [ GS.STAT_MANA_REGEN ], entryPct )
    , ( "Run Speed", [ GS.STAT_MOVEMENT_SPEED ], entryPct ) -- currently a constant
    , ( "Gold from All Sources", [ STAT_GOLD ], entryPct )
    , ( "Bonus Gold Chance (×5)", [ STAT_GOLD ], entryPct )
    , ( "Boss Gold", [ STAT_BOSS_GOLD ], entryPct )
    , ( "Clickable Find Chance", [ STAT_CLICKABLE_CHANCE ], entryPct ) -- not in total stats; skill-tree-stats only
    , ( "Clickable Gold Multiplier", [ STAT_CLICKABLE_GOLD ], entryPct ) -- not in total stats; skill-tree-stats only
    , ( "Treasure Chest Chance", [ STAT_TREASURE_CHEST_CHANCE ], entryPct )
    , ( "Treasure Chest Gold", [ STAT_TREASURE_CHEST_GOLD ], entryPct )
    , ( "Item Cost Reduction", [ STAT_ITEM_COST_REDUCTION ], entryPct )

    -- ancient shards (not in tree-stats; total-stats only)
    , ( "Weapon Damage", [ STAT_ITEM_WEAPON_DAMAGE ], entryPct )
    , ( "Helm Damage", [ STAT_ITEM_HEAD_DAMAGE ], entryPct )
    , ( "Chest Damage", [ STAT_ITEM_CHEST_DAMAGE ], entryPct )
    , ( "Ring Damage", [ STAT_ITEM_RING_DAMAGE ], entryPct )
    , ( "Legging Damage", [ STAT_ITEM_LEGS_DAMAGE ], entryPct )
    , ( "Gloves Damage", [ STAT_ITEM_HANDS_DAMAGE ], entryPct )
    , ( "Boots Damage", [ STAT_ITEM_FEET_DAMAGE ], entryPct )
    , ( "Cape Damage", [ STAT_ITEM_BACK_DAMAGE ], entryPct )
    ]


skillEntrySpecs : List StatsEntrySpec
skillEntrySpecs =
    -- I made these up, no basis on in-game ui
    [ ( "Multiclick Clicks (no flurry/frenzy yet)", [ ExtraMulticlicks ], entryInt )
    , ( "Multiclick Energy Cost", [ MulticlickCost ], entryInt )
    , ( "Big Clicks Stacks", [ BigClicksStacks ], entryInt )
    , ( "Big Clicks Damage Multiplier", [ BigClicksDamage ], entryPct )
    , ( "Huge Click Damage Multiplier", [ HugeClickDamage ], entryPct )
    , ( "Mana Crit Damage Multiplier", [ ManaCritDamage ], entryPct )
    ]


stat1 : List GS.StatTotal -> GS.StatTotal
stat1 stats =
    case stats of
        [ a ] ->
            a

        _ ->
            Debug.crash "expected 1 stat" stats


stat2 : List GS.StatTotal -> ( GS.StatTotal, GS.StatTotal )
stat2 stats =
    case stats of
        [ a, b ] ->
            ( a, b )

        _ ->
            Debug.crash "expected 2 stats" stats


entryPct =
    stat1 >> \stat -> Just <| pct stat.val


entryFloat =
    stat1 >> \stat -> Just <| float stat.val


entrySec base =
    stat1 >> \stat -> Just <| sec <| base / Time.second / stat.val


entryInt =
    stat1 >> \stat -> Just <| int stat.val


viewStatsSummary : List GS.StatTotal -> H.Html msg
viewStatsSummary statList =
    let
        getStat =
            GS.statTable statList

        toEntry ( label, statIds, format ) =
            let
                stats =
                    statIds |> List.map getStat

                level =
                    (stats |> List.map .level |> List.sum) // max 1 (List.length stats)
            in
                { label = label, level = level, value = format stats }
    in
        H.div [ A.class "stats-summary" ]
            [ H.p [] [ H.text "Stats summary:" ]
            , H.table [] (statEntrySpecs ++ skillEntrySpecs |> List.map (toEntry >> viewStatEntry) |> Maybe.Extra.values)
            ]


viewStatEntry : { label : String, level : Int, value : Maybe String } -> Maybe (H.Html msg)
viewStatEntry { label, level, value } =
    Maybe.map
        (\value ->
            H.tr
                [ A.class <| "level-" ++ statLevelTier level
                , A.title <| "Level " ++ toString level
                ]
                [ H.td [] [ H.text <| label ++ ": " ]
                , H.td [ A.class "stat-value" ] [ H.text value ]

                -- , H.td [ A.class "stat-level" ] [ H.text <| "Level " ++ toString level ]
                ]
        )
        value


pct : Float -> String
pct f =
    (f * 100 |> floor |> toString) ++ "%"


float : Float -> String
float f =
    let
        sigfigs =
            3

        exp =
            10 ^ sigfigs
    in
        (f * exp |> floor |> toFloat) / exp |> toString


sec : Float -> String
sec f =
    float f ++ "s"


pct0 f =
    pct <| f - 1


negPct f =
    if f == 1 then
        "-0%"
    else
        pct0 f


int =
    toString << floor


statLevelTier : Int -> String
statLevelTier level =
    if level > 7 then
        "high"
    else if level > 3 then
        "mid"
    else
        "low"


viewSelectSave : Route.Features -> List (H.Html M.Msg)
viewSelectSave features =
    if features.importSave then
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
