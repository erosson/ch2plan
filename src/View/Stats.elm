module View.Stats exposing (view, viewNodeSummary, viewStatsSummary)

import Dict as Dict exposing (Dict)
import GameData as G
import GameData.Stats as GS exposing (Stat(..))
import Html as H
import Html.Attributes as A
import Html.Events as E
import Maybe.Extra
import Model as M
import Model.Skill as Skill
import Route
import Set as Set exposing (Set)
import Time
import View.Graph
import View.Spreadsheet


view : M.Model -> Route.HomeParams -> H.Html msg
view model params =
    case M.parseStatsSummary model params of
        Err err ->
            H.div [] [ H.text <| "error: " ++ err ]

        Ok ({ game, char, selected, stats, nodes } as summary) ->
            let
                getStat =
                    GS.statTable stats
            in
            H.div []
                [ H.p []
                    [ H.a [ Route.href <| Route.Home params ] [ H.text "View Skill Tree" ] ]
                , H.p [ A.title "I haven't seen an official name for those blue nodes in CH2, so I stole Path of Exile's name for nodes like that." ]
                    [ H.text "⚠ Warning: most of the blue "
                    , H.span [ A.class "node-Keystone" ] [ H.text "Keystone Nodes" ]
                    , H.text " have no effect on these stat calculations yet. Work is in progress. Please be patient. (All other nodes should work.)"
                    ]
                , H.div [ A.class "stats-flex" ]
                    [ H.div [ A.class "stats-box skills-summary" ]
                        [ H.p [] [ H.text "Skills:" ]
                        , H.ul [] (List.map (viewSkillSummary game.stats.rules getStat) <| List.filter (\s -> not <| Set.member s.id skillBlacklist) <| Dict.values char.skills)
                        ]
                    , H.div [ A.class "stats-box" ]
                        [ H.p [] [ H.text "Statistics:" ]
                        , viewStatsSummary getStat
                        ]
                    , H.div [ A.class "stats-box" ]
                        [ H.p []
                            [ H.a [ Route.href <| Route.Home params ] [ H.text <| String.fromInt (Set.size selected) ++ " skill points:" ]
                            , H.text " ("
                            , H.a [ Route.href <| Route.StatsTSV params ] [ H.text "spreadsheet format" ]

                            -- , H.textarea [ A.rows 1, A.cols 5, A.readonly True ] [ H.text <| View.Spreadsheet.format model summary ]
                            , H.text ")"
                            ]
                        , viewNodeSummary True nodes
                        ]
                    ]
                ]


skillBlacklist =
    -- quick-and-dirty way to avoid rendering unused skills
    Set.fromList [ "Clickdrizzle", "EnergizeExtend", "EnergizeRush" ]


viewSkillSummary : GS.Rules -> (GS.Stat -> GS.StatTotal) -> G.Skill -> H.Html msg
viewSkillSummary rules getStat skill =
    let
        lines =
            -- all of these lines are conditional: displayed if and only if the far-left skill-field or stat exists (ie. is not Nothing).
            [ Skill.energyCost getStat skill |> Maybe.map (int >> (\c -> ( "Energy Cost", "", c )))
            , Skill.manaCost getStat skill |> Maybe.map (int >> (\c -> ( "Mana Cost", "", c )))
            , Skill.cooldown getStat skill |> Maybe.map (sec 1 >> (\c -> ( "Cooldown", "", c )))
            , Skill.duration rules getStat skill |> Maybe.map (sec 1 >> (\c -> ( "Duration", "", c )))
            , Skill.uptime rules getStat skill |> Maybe.map (pct >> (\c -> ( "Uptime", "Duration / cooldown. The amount of time this buff can be active. 100% means it's always active, if you can pay its mana cost.", c )))
            , Skill.damage getStat skill |> Maybe.map (pct >> (\c -> ( "Damage", "", c )))
            , Skill.stacks getStat skill |> Maybe.map (int >> (\c -> ( "Stacks", "", c )))
            , Skill.effect getStat skill |> Maybe.map (pct >> (\c -> ( "Effect", "", c )))
            ]
                |> Maybe.Extra.values
                |> List.map
                    (\( label, tooltip, value ) ->
                        H.li [ A.class "stat-line", A.title tooltip ]
                            [ H.span [ A.class "stat-label" ] [ H.text <| label ++ ": " ]
                            , H.span [ A.class "stat-value" ] [ H.text value ]
                            ]
                    )
    in
    H.li []
        [ H.img [ A.class "skill-icon", A.src <| "./ch2data/img/skills/" ++ String.fromInt skill.iconId ++ ".png" ] [], H.b [] [ H.text skill.name ], H.ul [] lines ]


viewStatsSummary : (GS.Stat -> GS.StatTotal) -> H.Html msg
viewStatsSummary getStat =
    let
        toEntry ( label, statIds, format ) =
            let
                stats =
                    statIds |> List.map getStat

                level =
                    (stats |> List.map .level |> List.sum) // max 1 (List.length stats)
            in
            { label = label, level = level, value = format stats }
    in
    H.table [ A.class "stats-summary" ] (statEntrySpecs |> List.map (toEntry >> viewStatEntry) |> Maybe.Extra.values)


type alias StatsEntrySpec =
    ( String, List GS.Stat, List GS.StatTotal -> Maybe String )


statEntrySpecs : List StatsEntrySpec
statEntrySpecs =
    -- try to match the order of the in-game stats screen here. See scripts/ui/StatsSubtab.as
    --
    -- autoattack damage
    -- click damage
    [ ( "Click Damage Multiplier", [ STAT_CLICK_DAMAGE ], entryPct ) -- not actually in the stats screen, only flat click damage
    , ( "Autoattack Damage Multiplier", [ STAT_AUTOATTACK_DAMAGE ], entryPct )
    , ( "Attack Delay", [ STAT_HASTE ], entrySec 600 )

    -- damage multiplier from level
    -- energy from auto attacks - currently a constant, not useful here
    , ( "Global Cooldown Time", [ STAT_HASTE ], entrySec 2000 ) -- TODO that one keystone for <1 sec
    , ( "Automator Speed", [ STAT_AUTOMATOR_SPEED ], entryPct )
    , ( "Critical Chance", [ STAT_CRIT_CHANCE ], entryPct )
    , ( "Critical Damage Multiplier", [ STAT_CRIT_DAMAGE ], entryPct )
    , ( "Haste", [ STAT_HASTE ], entryPct )
    , ( "Maximum Energy", [ STAT_TOTAL_ENERGY ], entryInt )
    , ( "Maximum Mana", [ STAT_TOTAL_MANA ], entryInt )
    , ( "Mana Regeneration", [ GS.STAT_MANA_REGEN ], entryPct )
    , ( "Run Speed", [ GS.STAT_MOVEMENT_SPEED ], entryPct ) -- currently a constant
    , ( "Gold from All Sources", [ STAT_GOLD ], entryPct )
    , ( "Bonus Gold Chance (×10)", [ STAT_BONUS_GOLD_CHANCE ], entryPct ) -- the multiplier is datamined from heroclickerlib/managers/Formulas.as
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


stat1 : List GS.StatTotal -> GS.StatTotal
stat1 stats =
    case stats of
        [ a ] ->
            a

        _ ->
            Debug.todo "expected 1 stat" stats


stat2 : List GS.StatTotal -> ( GS.StatTotal, GS.StatTotal )
stat2 stats =
    case stats of
        [ a, b ] ->
            ( a, b )

        _ ->
            Debug.todo "expected 2 stats" stats


entryPct =
    stat1 >> (\stat -> Just <| pct stat.val)


entryFloat =
    stat1 >> (\stat -> Just <| float 3 stat.val)


entrySec base =
    stat1 >> (\stat -> Just <| sec 1 <| base / 1000 / stat.val)


entryInt =
    stat1 >> (\stat -> Just <| int stat.val)


viewStatEntry : { label : String, level : Int, value : Maybe String } -> Maybe (H.Html msg)
viewStatEntry { label, level, value } =
    Maybe.map
        (\val ->
            H.tr
                [ A.class <| "level-" ++ statLevelTier level
                , A.title <| "Level " ++ String.fromInt level
                ]
                [ H.td [] [ H.text <| label ++ ": " ]
                , H.td [ A.class "stat-value" ] [ H.text val ]

                -- , H.td [ A.class "stat-level" ] [ H.text <| "Level " ++ toString level ]
                ]
        )
        value


pct : Float -> String
pct f =
    (f * 100 |> floor |> String.fromInt) ++ "%"


float : Int -> Float -> String
float sigfigs f =
    let
        exp =
            10 ^ toFloat sigfigs
    in
    (f * exp |> floor |> toFloat) / exp |> String.fromFloat


sec : Int -> Float -> String
sec sigfigs f =
    float sigfigs f ++ "s"


pct0 f =
    pct <| f - 1


negPct f =
    if f == 1 then
        "-0%"

    else
        pct0 f


int =
    String.fromInt << floor


statLevelTier : Int -> String
statLevelTier level =
    if level > 7 then
        "high"

    else if level > 3 then
        "mid"

    else
        "low"


viewNodeSummary : Bool -> List ( Int, G.NodeType ) -> H.Html msg
viewNodeSummary showTooltips ns =
    H.ul [ A.class "node-summary" ] <|
        if List.length ns == 0 then
            []

        else
            List.map ((\f ( a, b ) -> f a b) <| viewNodeSummaryLine showTooltips) ns


viewNodeSummaryLine : Bool -> Int -> G.NodeType -> H.Html msg
viewNodeSummaryLine showTooltips count nodeType =
    let
        tooltip =
            if showTooltips then
                G.tooltip nodeType "" |> Just

            else
                Nothing
    in
    H.li [ A.class <| View.Graph.nodeQualityClass nodeType.quality ]
        [ H.div [ A.class "icon" ]
            [ H.img [ A.class "icon-background", A.src <| View.Graph.nodeBackgroundImage nodeType False False False ] []
            , H.img [ A.class "icon-main", A.src <| View.Graph.iconUrl nodeType ] []
            ]
        , H.div []
            [ H.text <|
                " "
                    ++ (if count /= 1 then
                            String.fromInt count ++ "× "

                        else
                            ""
                       )
            , H.b [] [ H.text nodeType.name ]
            , H.span [] [ H.text <| Maybe.Extra.unwrap "" ((++) ": ") tooltip ]
            ]

        -- , H.div [] [ H.text <| Maybe.withDefault "" nodeType.tooltip ]
        , H.div [ A.class "clear" ] []

        -- , H.text <| toString nodeType
        ]
