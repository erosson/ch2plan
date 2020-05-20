module View.Stats exposing (view, viewNodeSummary, viewStatsSummary)

import Dict exposing (Dict)
import GameData exposing (GameData)
import GameData.Stats as Stats exposing (Stat(..))
import Html as H exposing (..)
import Html.Attributes as A exposing (..)
import Html.Events as E exposing (..)
import Maybe.Extra
import Model exposing (Model)
import Model.Skill as Skill
import Result.Extra
import Route
import Set exposing (Set)
import Time
import View.Spreadsheet
import View.Util


view : Model -> GameData -> Route.HomeParams -> Html msg
view model gameData params =
    case Model.parseStatsSummary gameData params of
        Err err ->
            div [] [ text <| "error: " ++ err ]

        Ok ({ game, char, selected, stats, nodes } as summary) ->
            let
                getStat =
                    Stats.statTable stats
            in
            div []
                [ p []
                    [ a [ Route.href <| Route.Home params ] [ text "View Skill Tree" ] ]
                , p [ title "I haven't seen an official name for those blue nodes in CH2, so I stole Path of Exile's name for nodes like that." ]
                    [ text "⚠ Warning: most of the blue "
                    , span [ class "node-Keystone" ] [ text "Keystone Nodes" ]
                    , text " have no effect on these stat calculations yet. Work is in progress. Please be patient. (All other nodes should work.)"
                    ]
                , div [ class "stats-flex" ]
                    [ div [ class "stats-box skills-summary" ]
                        [ p [] [ text "Skills:" ]
                        , ul [] (List.map (viewSkillSummary game.stats.rules getStat) <| List.filter (\s -> not <| Set.member s.id skillBlacklist) <| Dict.values char.skills)
                        ]
                    , div [ class "stats-box" ]
                        [ p [] [ text "Statistics:" ]
                        , viewStatsSummary getStat
                        ]
                    , div [ class "stats-box" ]
                        [ p []
                            [ a [ Route.href <| Route.Home params ] [ text <| String.fromInt (Set.size selected) ++ " skill points:" ]
                            , text " ("
                            , a [ Route.href <| Route.StatsTSV params ] [ text "spreadsheet format" ]

                            -- , textarea [ rows 1, cols 5, readonly True ] [ text <| View.Spreadsheet.format model summary ]
                            , text ")"
                            ]
                        , viewNodeSummary True nodes
                        ]
                    ]
                ]


skillBlacklist =
    -- quick-and-dirty way to avoid rendering unused skills
    Set.fromList [ "Clickdrizzle", "EnergizeExtend", "EnergizeRush" ]


viewSkillSummary : Stats.Rules -> (Stat -> Result String Stats.StatTotal) -> GameData.Skill -> Html msg
viewSkillSummary rules getStat skill =
    let
        lines =
            -- all of these lines are conditional: displayed if and only if the far-left skill-field or stat exists (ie. is not Nothing).
            [ Skill.energyCost getStat skill |> Result.map (int >> (\c -> ( "Energy Cost", "", c )))
            , Skill.manaCost getStat skill |> Result.map (int >> (\c -> ( "Mana Cost", "", c )))
            , Skill.cooldown getStat skill |> Result.map (sec 1 >> (\c -> ( "Cooldown", "", c )))
            , Skill.duration rules getStat skill |> Result.map (sec 1 >> (\c -> ( "Duration", "", c )))
            , Skill.uptime rules getStat skill |> Result.map (pct >> (\c -> ( "Uptime", "Duration / cooldown. The amount of time this buff can be active. 100% means it's always active, if you can pay its mana cost.", c )))
            , Skill.damage getStat skill |> Result.map (pct >> (\c -> ( "Damage", "", c )))
            , Skill.stacks getStat skill |> Result.map (int >> (\c -> ( "Stacks", "", c )))
            , Skill.effect getStat skill |> Result.map (pct >> (\c -> ( "Effect", "", c )))
            ]
                |> List.filterMap Result.toMaybe
                |> List.map
                    (\( label, tooltip, value ) ->
                        li [ class "stat-line", title tooltip ]
                            [ span [ class "stat-label" ] [ text <| label ++ ": " ]
                            , span [ class "stat-value" ] [ text value ]
                            ]
                    )
    in
    li []
        [ img [ class "skill-icon", src <| "./ch2data/img/skills/" ++ String.fromInt skill.iconId ++ ".png" ] [], b [] [ text skill.name ], ul [] lines ]


viewStatsSummary : (Stats.Stat -> Result String Stats.StatTotal) -> Html msg
viewStatsSummary getStat =
    let
        toEntry ( label, statId, format ) =
            getStat statId
                |> Result.map (\stat -> { label = label, level = stat.level, value = format stat })
    in
    table [ class "stats-summary" ]
        (statEntrySpecs
            |> List.map toEntry
            |> List.filterMap Result.toMaybe
            |> List.filterMap viewStatEntry
        )


type alias StatsEntrySpec =
    ( String, Stat, Stats.StatTotal -> Maybe String )


statEntrySpecs : List StatsEntrySpec
statEntrySpecs =
    -- try to match the order of the in-game stats screen here. See scripts/ui/StatsSubtab.as
    --
    -- autoattack damage
    -- click damage
    [ ( "Click Damage Multiplier", STAT_CLICK_DAMAGE, entryPct ) -- not actually in the stats screen, only flat click damage
    , ( "Autoattack Damage Multiplier", STAT_AUTOATTACK_DAMAGE, entryPct )
    , ( "Attack Delay", STAT_HASTE, entrySec 600 )

    -- damage multiplier from level
    -- energy from auto attacks - currently a constant, not useful here
    , ( "Global Cooldown Time", STAT_HASTE, entrySec 2000 ) -- TODO that one keystone for <1 sec
    , ( "Automator Speed", STAT_AUTOMATOR_SPEED, entryPct )
    , ( "Critical Chance", STAT_CRIT_CHANCE, entryPct )
    , ( "Critical Damage Multiplier", STAT_CRIT_DAMAGE, entryPct )
    , ( "Haste", STAT_HASTE, entryPct )
    , ( "Maximum Energy", STAT_TOTAL_ENERGY, entryInt )
    , ( "Maximum Mana", STAT_TOTAL_MANA, entryInt )
    , ( "Mana Regeneration", STAT_MANA_REGEN, entryPct )
    , ( "Run Speed", STAT_MOVEMENT_SPEED, entryPct ) -- currently a constant
    , ( "Gold from All Sources", STAT_GOLD, entryPct )
    , ( "Bonus Gold Chance (×10)", STAT_BONUS_GOLD_CHANCE, entryPct ) -- the multiplier is datamined from heroclickerlib/managers/Formulas.as
    , ( "Boss Gold", STAT_BOSS_GOLD, entryPct )
    , ( "Clickable Find Chance", STAT_CLICKABLE_CHANCE, entryPct ) -- not in total stats; skill-tree-stats only
    , ( "Clickable Gold Multiplier", STAT_CLICKABLE_GOLD, entryPct ) -- not in total stats; skill-tree-stats only
    , ( "Treasure Chest Chance", STAT_TREASURE_CHEST_CHANCE, entryPct )
    , ( "Treasure Chest Gold", STAT_TREASURE_CHEST_GOLD, entryPct )
    , ( "Item Cost Reduction", STAT_ITEM_COST_REDUCTION, entryPct )

    -- ancient shards (not in tree-stats; total-stats only)
    , ( "Weapon Damage", STAT_ITEM_WEAPON_DAMAGE, entryPct )
    , ( "Helm Damage", STAT_ITEM_HEAD_DAMAGE, entryPct )
    , ( "Chest Damage", STAT_ITEM_CHEST_DAMAGE, entryPct )
    , ( "Ring Damage", STAT_ITEM_RING_DAMAGE, entryPct )
    , ( "Legging Damage", STAT_ITEM_LEGS_DAMAGE, entryPct )
    , ( "Gloves Damage", STAT_ITEM_HANDS_DAMAGE, entryPct )
    , ( "Boots Damage", STAT_ITEM_FEET_DAMAGE, entryPct )
    , ( "Cape Damage", STAT_ITEM_BACK_DAMAGE, entryPct )
    ]


entryPct stat =
    Just <| pct stat.val


entryFloat stat =
    Just <| float 3 stat.val


entrySec base stat =
    Just <| sec 1 <| base / 1000 / stat.val


entryInt stat =
    Just <| int stat.val


viewStatEntry : { label : String, level : Int, value : Maybe String } -> Maybe (Html msg)
viewStatEntry { label, level, value } =
    Maybe.map
        (\val ->
            tr
                [ class <| "level-" ++ statLevelTier level
                , title <| "Level " ++ String.fromInt level
                ]
                [ td [] [ text <| label ++ ": " ]
                , td [ class "stat-value" ] [ text val ]

                -- , td [ class "stat-level" ] [ text <| "Level " ++ toString level ]
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


viewNodeSummary : Bool -> List ( Int, GameData.NodeType ) -> Html msg
viewNodeSummary showTooltips ns =
    ul [ class "node-summary" ] <|
        if List.length ns == 0 then
            []

        else
            List.map ((\f ( a, b ) -> f a b) <| viewNodeSummaryLine showTooltips) ns


viewNodeSummaryLine : Bool -> Int -> GameData.NodeType -> Html msg
viewNodeSummaryLine showTooltips count nodeType =
    let
        tooltip =
            if showTooltips then
                GameData.tooltip nodeType "" |> Just

            else
                Nothing
    in
    li [ class <| View.Util.nodeQualityClass nodeType.quality ]
        [ div [ class "icon" ]
            [ img [ class "icon-background", src <| View.Util.nodeBackgroundImage nodeType { isHighlighted = False, isSelected = False, isNeighbor = False } ] []
            , img [ class "icon-main", src <| View.Util.nodeIconUrl nodeType ] []
            ]
        , div []
            [ text <|
                " "
                    ++ (if count /= 1 then
                            String.fromInt count ++ "× "

                        else
                            ""
                       )
            , b [] [ text nodeType.name ]
            , span [] [ text <| Maybe.Extra.unwrap "" ((++) ": ") tooltip ]
            ]

        -- , div [] [ text <| Maybe.withDefault "" nodeType.tooltip ]
        , div [ class "clear" ] []

        -- , text <| toString nodeType
        ]
