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
    case Model.parseStatsSummary model gameData params of
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
                    [ if char.spells == [] then
                        div [ class "stats-box skills-summary" ]
                            [ p [] [ text "Skills:" ]
                            , ul [] (List.map (viewSkillSummary game.stats.rules getStat) <| List.filter (\s -> not <| Set.member s.id skillBlacklist) <| Dict.values char.skills)
                            ]

                      else
                        div [ class "stats-box spells-summary" ]
                            [ p [] [ text "Spells:" ]
                            , ul [] (List.map viewSpellSummary char.spells)
                            ]
                    , div [ class "stats-box" ]
                        [ p [] [ text "Statistics:" ]
                        , viewStatsSummary char getStat
                        ]
                    , div [ class "stats-box" ]
                        [ p []
                            [ a [ Route.href <| Route.Home params ] [ text <| String.fromInt (Set.size selected.set) ++ " skill points:" ]
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


viewSpellSummary : GameData.Spell -> Html msg
viewSpellSummary s =
    let
        lineIf : Bool -> List (Html msg) -> List (Html msg)
        lineIf b l =
            if b then
                l

            else
                []

        energy =
            toFloat (List.length s.runeCombination) * s.costMultiplier * 5 |> round

        damage =
            (2 ^ List.length s.runeCombination |> toFloat) * (25.0 / 4) * s.damageMultiplier

        durationSecs =
            ((List.length s.runeCombination - 1) * s.msecsPerRune |> toFloat) / 1000

        fats =
            GameData.spellFatigue s

        lines : List (List (Html msg))
        lines =
            [ []

            -- , lineIf (s.description /= "") [ text s.description ]
            , [ text "Runes: ", kbd [] [ s.runeCombination |> List.map String.fromInt |> String.join " " |> text ] ]
            , lineIf (s.damageMultiplier > 0) [ text <| "Damage: ×" ++ String.fromFloat damage ]
            , lineIf (durationSecs > 0) [ text <| "Cast time: " ++ String.fromFloat durationSecs ++ "s" ]
            , lineIf (s.manaCost > 0) [ text <| "Mana cost: " ++ String.fromInt s.manaCost ]
            , lineIf (energy > 0) [ text <| "Energy cost: " ++ String.fromInt energy ]
            , lineIf (fats /= [])
                [ text <| "Fatigue: "
                , fats
                    |> List.map (\( fat, val ) -> String.fromInt val ++ "× " ++ fat.label)
                    |> String.join ", "
                    |> text
                ]
            ]
    in
    li []
        [ b [] [ text s.displayName ]
        , ul [] (lines |> List.filter ((/=) []) |> List.map (li []))
        ]


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
        [ img [ class "skill-icon", src <| "./ch2data/img/skills/" ++ String.fromInt skill.iconId ++ ".png" ] []
        , b [] [ text skill.name ]
        , ul [] lines
        ]


viewStatsSummary : GameData.Character -> (Stats.Stat -> Result String Stats.StatTotal) -> Html msg
viewStatsSummary char getStat =
    let
        toEntry ( label, statId, format ) =
            getStat statId
                |> Result.map (\stat -> { label = label, level = stat.level, value = format stat })

        stats =
            case String.toLower char.name of
                "wizard" ->
                    cursorStatEntrySpecs

                _ ->
                    cidStatEntrySpecs
    in
    div []
        (stats
            |> List.map
                (\( label, group ) ->
                    details [ A.attribute "open" "open" ]
                        [ summary [] [ text label ]
                        , table [ class "stats-summary" ]
                            (group
                                |> List.map toEntry
                                |> List.filterMap Result.toMaybe
                                |> List.filterMap viewStatEntry
                            )
                        ]
                )
        )


type alias StatsEntrySpec =
    ( String, Stat, Stats.StatTotal -> Maybe String )


cursorStatEntrySpecs : List ( String, List StatsEntrySpec )
cursorStatEntrySpecs =
    [ ( "Ice"
      , [ ( "Ice Spell Cost Reduction", ICE_COST_REDUCTION_PERCENT_PER_LEVEL, entryPct )
        , ( "Ice Damage from Crits", ICE_CRIT_DAMAGE_PERCENT, entryPct )
        , ( "Ice Damage", ICE_ADDITIONAL_PERCENT_DAMAGE, entryPct )
        , ( "Cool Crits Chance of Critical Hit", ICE_COOL_CRITICALS_CRIT_CHANCE_PERCENT, entryPct )
        , ( "Shatter Damage", SHATTER_DAMAGE_PERCENT, entryPct )
        , ( "Monsters Effected by Shatter", SHATTER_NUM_MONSTERS, entryInt )
        , ( "Ice Chance of Crit", ICE_CRIT_PERCENT_CHANCE, entryPct )
        , ( "Cool Criticals Duration", ICE_COOL_CRITICALS_DURATION_SECONDS, entrySecAdd )
        , ( "Ice Corrosion Damage", ICE_CORROSION_PERCENT_DAMAGE_INCREASE, entryPct )
        , ( "Ice Chain Chance", ICE_CHAIN_CHANCE_PERCENT, entryPct )

        -- TODO transcension; not yet represented by our stats
        -- , ( "Synergy Ice Lighting Duration", STAT_CLICK_DAMAGE, entrySecAdd )
        -- , ( "Synergy Ice Fire Duration", STAT_CLICK_DAMAGE, entrySecAdd )
        , ( "Cold Front Duration", COLD_FRONT_DURATION_TRAIT, entrySecAdd )
        , ( "Cold Front Damage", COLD_FRONT_DAMAGE_TRAIT, entryPct )
        , ( "Cold Front Chance Per Rank", COLD_FRONT_ACTIVATION_CHANCE_PER_RANK, entryPct )
        , ( "Ice Fire Symbiosis Damage", ICE_FIRE_SYMBIOSIS, entryPct )
        , ( "Ice Lightning Symbiosis Damage", ICE_LIGHTNING_SYMBIOSIS, entryPct )
        ]
      )
    , ( "Fire"
      , [ ( "Fire Spell Cost Reduction", FIRE_COST_REDUCTION_PERCENT_PER_LEVEL, entryPct )
        , ( "Fire Damage from Crits", FIRE_CRIT_DAMAGE_PERCENT, entryPct )
        , ( "Fire Damage", FIRE_ADDITIONAL_PERCENT_DAMAGE, entryPct )
        , ( "Chance of Combustion", FIRE_COMBUSTION_CHANCE_PERCENT, entryPct )
        , ( "Combustion Duration", FIRE_COMBUSTION_DURATION_SECONDS, entrySecAdd )
        , ( "Explosion Damage", FIRE_EXPLOSION_DAMAGE_PERCENT, entryPct )
        , ( "Explosion Damage Dealt to Next Monster", FIRE_EXPLOSION_DAMAGE_PERCENT, entryPct )
        , ( "Fire Additional Damage from Corrosion", FIRE_CORROSION_PERCENT_DAMAGE_INCREASE, entryPct )
        , ( "Fire Zap Percent Damage", FIRE_ZAP_PERCENT_DAMAGE, entryPct )
        , ( "Fire Burn Damage", FIRE_BURN_PERCENT_DAMAGE_INCREASE, entryPct )

        -- TODO not yet represented by our stats
        -- , ( "Synergy Lightning Fire Duration", STAT_CLICK_DAMAGE, entrySecAdd)
        -- , ( "Synergy Ice Fire Duration", STAT_CLICK_DAMAGE, entrySecAdd)
        , ( "Heat Burst Duration", HEAT_BURST_DURATION_TRAIT, entrySecAdd )
        , ( "Heat Burst Damage", HEAT_BURST_DAMAGE_TRAIT, entryPct )
        , ( "Heat Burst Chance Per Rank", HEAT_BURST_ACTIVATION_CHANCE_PER_RANK, entryPct )
        , ( "Ice Fire Symbiosis Damage", ICE_FIRE_SYMBIOSIS, entryPct )
        , ( "Lightning Fire Symbiosis Damage", FIRE_LIGHTNING_SYMBIOSIS, entryPct )
        ]
      )
    , ( "Lightning"
      , [ ( "Lightning Spell Cost Reduction", LIGHTNING_COST_REDUCTION_PERCENT_PER_LEVEL, entryPct )
        , ( "Lightning Chance of Crit", LIGHTNING_CRIT_PERCENT_CHANCE, entryPct )
        , ( "Lightning Damage", LIGHTNING_ADDITIONAL_PERCENT_DAMAGE, entryPct )
        , ( "Flash % Chance of Striking Adtl. Times", LIGHTNING_FLASH_SPEED_INCREASE_PERCENT, entryPct )
        , ( "Flash Spell Count", LIGHTNING_FLASH_NUM_SPELLS, entryInt )
        , ( "Lightning Circuit Damage", LIGHTNING_CIRCUIT_DAMAGE_PERCENT, entryPct )
        , ( "Lightning Chain Chance", LIGHTNING_CHAIN_PERCENT, entryPct )
        , ( "Lightning Zap Percent Damage", LIGHTNING_ZAP_PERCENT_DAMAGE, entryPct )
        , ( "Lightning Burn Damage", LIGHTNING_BURN_PERCENT_DAMAGE_INCREASE, entryPct )

        -- TODO not yet represented by our stats
        -- , ( "Synergy Ice Lighting Duration", STAT_CLICK_DAMAGE, entrySecAdd )
        -- , ( "Synergy Lightning Fire Duration", STAT_CLICK_DAMAGE, entrySecAdd )
        , ( "Thunderstorm Duration ", THUNDERSTORM_DURATION_TRAIT, entrySecAdd )
        , ( "Thunderstorm Damage", THUNDERSTORM_DAMAGE_TRAIT, entryPct )
        , ( "Thunderstorm Chance Per Rank", THUNDERSTORM_ACTIVATION_CHANCE_PER_RANK, entryPct )
        , ( "Ice Lightning Symbiosis Damage", ICE_LIGHTNING_SYMBIOSIS, entryPct )
        , ( "Lightning Fire Symbiosis Damage", FIRE_LIGHTNING_SYMBIOSIS, entryPct )
        ]
      )
    ]


cidStatEntrySpecs : List ( String, List StatsEntrySpec )
cidStatEntrySpecs =
    [ ( "Stats"
      , -- try to match the order of the in-game stats screen here. See scripts/ui/StatsSubtab.as
        [ ( "Click Damage", STAT_CLICK_DAMAGE, entryPct )
        , ( "Auto Attack Damage", STAT_AUTOATTACK_DAMAGE, entryPct )
        , ( "Critical Chance", STAT_CRIT_CHANCE, entryPct )
        , ( "Critical Damage Multiplier", STAT_CRIT_DAMAGE, entryPct )
        , ( "Haste", STAT_HASTE, entryPct )
        , ( "Gold Received", STAT_GOLD, entryPct )
        , ( "Monster Gold", STAT_MONSTER_GOLD, entryPct )
        , ( "Bonus Gold Chance (×10)", STAT_BONUS_GOLD_CHANCE, entryPct ) -- the multiplier is datamined from heroclickerlib/managers/Formulas.as
        , ( "Clickable Chance", STAT_CLICKABLE_CHANCE, entryPct )
        , ( "Clickable Gold", STAT_CLICKABLE_GOLD, entryPct )
        , ( "Treasure Chest Chance", STAT_TREASURE_CHEST_CHANCE, entryPct )
        , ( "Treasure Chest Gold", STAT_TREASURE_CHEST_GOLD, entryPct )
        , ( "Item Cost Reduction", STAT_ITEM_COST_REDUCTION, entryPct )
        , ( "Total Energy", STAT_TOTAL_ENERGY, entryInt )
        , ( "Total Mana", STAT_TOTAL_MANA, entryInt )
        , ( "Mana Regeneration", STAT_MANA_REGEN, entryPct )
        , ( "Weapon Damage", STAT_ITEM_WEAPON_DAMAGE, entryPct )
        , ( "Helmet Damage", STAT_ITEM_HEAD_DAMAGE, entryPct )
        , ( "Breastplate Damage", STAT_ITEM_CHEST_DAMAGE, entryPct )
        , ( "Ring Damage", STAT_ITEM_RING_DAMAGE, entryPct )
        , ( "Pants Damage", STAT_ITEM_LEGS_DAMAGE, entryPct )
        , ( "Gloves Damage", STAT_ITEM_HANDS_DAMAGE, entryPct )
        , ( "Boots Damage", STAT_ITEM_FEET_DAMAGE, entryPct )
        , ( "Cape Damage", STAT_ITEM_BACK_DAMAGE, entryPct )
        ]
      )
    , ( "Traits"
      , [ ( "Increased MultiClicks", MultiClick_stacks, entryInt )
        , ( "More Big Clicks", BigClicks_stacks, entryInt )
        , ( "Bigger Big Clicks", BigClicks_damage, entryPct )
        , ( "Improved Energize", Energize_duration, entrySecAdd )
        , ( "Huger Huge Click", HugeClick_damage, entryPct )
        , ( "Sustained Powersurge", Powersurge_duration, entrySecAdd )
        , ( "Mana Crit Damage", ManaCrit_damage, entryPct )
        , ( "Improved Powersurge", Powersurge_damage, entryPct )
        , ( "Reload Energy and Mana", Reload_effect, entryInt ) -- not on the stats screen, but useful
        ]
      )
    , ( "Misc"
      , [ ( "Attack Delay", STAT_HASTE, entrySecDiv 600 )
        , ( "Global Cooldown Time", STAT_HASTE, entrySecDiv 2000 )
        , ( "Automator Speed", STAT_AUTOMATOR_SPEED, entryPct )
        ]
      )
    ]


entryPct stat =
    Just <| pct stat.val


entryFloat stat =
    Just <| float 3 stat.val


entrySecAdd stat =
    Just <| int stat.val ++ "sec"


entrySecDiv base stat =
    Just <| sec 1 <| base / 1000 / stat.val


entryInt stat =
    Just <| int stat.val


viewStatEntry : { label : String, level : Int, value : Maybe String } -> Maybe (Html msg)
viewStatEntry { label, level, value } =
    Maybe.map
        (\val ->
            tr
                [ class <| "level-" ++ statLevelTier level
                ]
                [ td [] [ text <| label ++ ": " ]
                , td [ class "stat-value" ] [ text val ]
                , td [ class "stat-level" ] [ text " (", text <| String.fromInt level, text ")" ]

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


viewNodeSummary : Bool -> List Model.NodeTypeSummary -> Html msg
viewNodeSummary showTooltips ns =
    ul [ class "node-summary" ] <|
        if List.length ns == 0 then
            []

        else
            List.map (viewNodeSummaryLine showTooltips) ns


viewNodeSummaryLine : Bool -> Model.NodeTypeSummary -> Html msg
viewNodeSummaryLine showTooltips { nodeType, count, transcendLevel } =
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
