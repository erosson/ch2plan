module GameData.Stats exposing
    ( Character
    , Growth(..)
    , Rules
    , Stat(..)
    , StatTotal
    , StatValue
    , Stats
    , TranscensionPerk
    , calcStat
    , calcStats
    , decoder
    , getStat
    , statTable
    )

import Dict exposing (Dict)
import Dict.Extra
import Json.Decode as D
import Json.Decode.Pipeline as P
import List.Extra
import Maybe.Extra
import Set exposing (Set)


type Growth
    = Noop
    | ExponentialMultiplier
    | Linear
    | LinearReciprocal
    | LinearReciprocalComplement
    | OnePlusLinearReciprocalComplement
    | LinearExponential
    | Constant


type alias StatValue =
    { base : Float, growth : Growth, args : List Float }


type alias Stats =
    { rules : Rules
    , statValueFunctions : Dict String StatValue
    , characters : Dict String Character
    }


type alias Character =
    { stats : Dict NodeType (List ( Stat, Int ))
    , transcensionPerks : Dict Int TranscensionPerk
    }


type alias TranscensionPerk =
    { costFunction : ( Growth, List Float )
    , trait : Maybe String
    }


type alias Rules =
    { hasteAffectsDuration : Bool }


rules0 : Rules
rules0 =
    { hasteAffectsDuration = False }


decoder : D.Decoder Stats
decoder =
    D.succeed Stats
        |> P.optional "rules" rulesDecoder rules0
        |> P.required "statValueFunctions" (D.dict statValueDecoder)
        |> P.required "characters" (D.dict charDecoder)


charDecoder : D.Decoder Character
charDecoder =
    D.succeed Character
        |> P.required "stats" (charStatsDecoder |> D.map charStatsByNodeType)
        |> P.optional "transcensionPerks"
            (D.keyValuePairs transcensionPerkDecoder
                |> D.map
                    (List.filterMap
                        (\( k, v ) ->
                            String.toInt k
                                |> Maybe.map (\ki -> ( ki, v ))
                        )
                        >> Dict.fromList
                    )
            )
            Dict.empty


transcensionPerkDecoder : D.Decoder TranscensionPerk
transcensionPerkDecoder =
    D.succeed TranscensionPerk
        |> P.required "costFunction"
            (D.succeed Tuple.pair
                |> P.custom (D.index 0 growthDecoder)
                |> P.custom (D.index 1 (D.list D.float))
            )
        |> P.optional "trait" (D.maybe D.string) Nothing


rulesDecoder : D.Decoder Rules
rulesDecoder =
    D.succeed Rules
        |> P.optional "hasteAffectsDuration" D.bool rules0.hasteAffectsDuration


type alias NodeType =
    String


type alias StatName =
    String


charStatsDecoder : D.Decoder (Dict StatName (List ( NodeType, Int )))
charStatsDecoder =
    D.oneOf
        -- Cid's stats: [node-name, levels-per-node]
        [ D.map2 (\a b -> ( a, b ))
            (D.index 0 D.string)
            (D.index 1 D.int)
            |> D.list

        -- Cursor's stats: {prefix, range, levels=1}
        -- Cursor has many more node-types, but many are identical and easily compacted by layer
        , D.map3
            (\prefix ( start, end ) level ->
                List.range start end
                    |> List.map (\i -> ( prefix ++ String.fromInt i, level ))
            )
            (D.field "prefix" D.string)
            (D.field "range"
                (D.map2 Tuple.pair
                    (D.index 0 D.int)
                    (D.index 1 D.int)
                )
            )
            (D.field "level" D.int
                |> D.maybe
                |> D.map (Maybe.withDefault 1)
            )
            |> D.list
            |> D.map List.concat
        ]
        |> D.dict


charStatsByNodeType : Dict StatName (List ( NodeType, Int )) -> Dict NodeType (List ( Stat, Int ))
charStatsByNodeType =
    Dict.toList
        >> List.concatMap
            (\( statName, nodes ) ->
                -- stats in the stats.json but not the GameData/Stats enum are ignored - old stats.json snapshots may have out-of-date old stats.
                nodes
                    |> List.map (\( node, levels ) -> getStat statName |> Maybe.map (\stat -> ( node, ( stat, levels ) )))
                    |> Maybe.Extra.values
            )
        >> Dict.Extra.groupBy Tuple.first
        >> Dict.map (always <| List.map Tuple.second)


statValueDecoder : D.Decoder StatValue
statValueDecoder =
    D.succeed StatValue
        |> P.custom (D.index 0 D.float)
        |> P.custom (D.index 1 growthDecoder)
        |> P.custom
            (D.index 2
                (D.oneOf
                    [ D.list D.float
                    , D.float |> D.map List.singleton
                    ]
                )
            )


growthDecoder : D.Decoder Growth
growthDecoder =
    D.string
        |> D.andThen
            (\str ->
                case str of
                    "noop" ->
                        D.succeed Noop

                    "exponentialMultiplier" ->
                        D.succeed ExponentialMultiplier

                    "linear" ->
                        D.succeed Linear

                    "linearReciprocal" ->
                        D.succeed LinearReciprocal

                    "linearReciprocalComplement" ->
                        D.succeed LinearReciprocalComplement

                    "onePlusLinearReciprocalComplement" ->
                        D.succeed OnePlusLinearReciprocalComplement

                    "linearExponential" ->
                        D.succeed LinearExponential

                    "constant" ->
                        D.succeed Constant

                    _ ->
                        D.fail <| "unknown stat growth function: " ++ str
            )


calcStat : Stats -> Stat -> Int -> Float
calcStat stats stat intlevel =
    let
        level =
            toFloat intlevel
    in
    case Dict.get (statToString stat) stats.statValueFunctions of
        Nothing ->
            -- trying to read a new stat from an old ch2 version!
            -- Debug.todo <| "Impossible. Perhaps the stats.json is incomplete. " ++ Debug.toString stat
            0

        Just statValue ->
            -- original functions for this are in Character.as!
            case statValue.growth of
                Noop ->
                    0

                ExponentialMultiplier ->
                    -- no longer used in new versions, still needed for old versions
                    let
                        factor =
                            statValue.args |> listAtDefault 0 1
                    in
                    statValue.base * (factor ^ level)

                Linear ->
                    let
                        scale =
                            statValue.args |> listAtDefault 0 0

                        base =
                            -- statvalue.base is for legacy; newer stats specify a base param
                            statValue.args |> listAtDefault 1 statValue.base
                    in
                    level * scale + base

                LinearReciprocal ->
                    let
                        scale =
                            statValue.args |> listAtDefault 0 0

                        base =
                            statValue.args |> listAtDefault 1 0
                    in
                    1 / (level * scale + base)

                LinearReciprocalComplement ->
                    let
                        scale =
                            statValue.args |> listAtDefault 0 0

                        base =
                            statValue.args |> listAtDefault 1 0

                        max =
                            statValue.args |> listAtDefault 2 1
                    in
                    max * (1 - 1 / (level * scale + base))

                OnePlusLinearReciprocalComplement ->
                    let
                        scale =
                            statValue.args |> listAtDefault 0 0

                        base =
                            statValue.args |> listAtDefault 1 0

                        max =
                            statValue.args |> listAtDefault 2 1
                    in
                    1 + max * (1 - 1 / (level * scale + base))

                LinearExponential ->
                    -- TODO
                    0

                Constant ->
                    -- TODO
                    0


listAt : Int -> List a -> Maybe a
listAt n =
    List.drop n >> List.head


listAtDefault : Int -> a -> List a -> a
listAtDefault n default =
    listAt n >> Maybe.withDefault default


sumStatLevels : List ( Stat, Int ) -> List ( Stat, Int )
sumStatLevels stats =
    let
        sums : Dict String Int
        sums =
            stats
                |> Dict.Extra.groupBy (Tuple.first >> statToString)
                |> Dict.map (List.map Tuple.second >> List.sum |> always)
    in
    statList
        |> List.map
            (\stat ->
                ( stat
                , Dict.get (statToString stat) sums
                    |> Maybe.withDefault 0
                )
            )


type alias StatTotal =
    { stat : Stat, level : Int, val : Float }


calcStats : Stats -> List ( Stat, Int ) -> List StatTotal
calcStats stats =
    sumStatLevels
        >> List.map
            (\( stat, level ) ->
                { stat = stat, level = level, val = calcStat stats stat level }
            )


type
    Stat
    -- cid
    = STAT_IDLE_GOLD
    | STAT_HASTE
    | STAT_GOLD
    | STAT_CRIT_DAMAGE
    | STAT_CRIT_CHANCE
    | STAT_TOTAL_ENERGY
    | STAT_TOTAL_MANA
    | STAT_BONUS_GOLD_CHANCE
    | STAT_ITEM_COST_REDUCTION
    | STAT_CLICK_DAMAGE
    | STAT_IDLE_DAMAGE
    | STAT_MOVEMENT_SPEED
    | STAT_PIERCE_CHANCE
    | STAT_MANA_REGEN
    | STAT_CLICKABLE_GOLD
    | STAT_TREASURE_CHEST_CHANCE
    | STAT_TREASURE_CHEST_GOLD
    | STAT_BOSS_GOLD
    | STAT_CLICKABLE_CHANCE
    | STAT_ENERGY_REGEN
    | STAT_DAMAGE
    | STAT_ENERGY_COST_REDUCTION
    | STAT_ITEM_WEAPON_DAMAGE
    | STAT_ITEM_HEAD_DAMAGE
    | STAT_ITEM_CHEST_DAMAGE
    | STAT_ITEM_RING_DAMAGE
    | STAT_ITEM_LEGS_DAMAGE
    | STAT_ITEM_HANDS_DAMAGE
    | STAT_ITEM_FEET_DAMAGE
    | STAT_ITEM_BACK_DAMAGE
    | STAT_AUTOMATOR_SPEED
    | STAT_AUTOATTACK_DAMAGE
      -- everything below is treated in the game code as "traits", not stats.
      -- I don't care, they calculate just fine as stats
    | MultiClick_stacks
    | MultiClick_energyCost
    | BigClicks_stacks
    | BigClicks_damage
    | HugeClick_damage
    | ManaCrit_damage
    | Clickstorm_cooldown
    | Energize_cooldown
    | Energize_manaCost
    | Energize_duration
    | Powersurge_cooldown
    | Powersurge_manaCost
    | Powersurge_duration
    | Powersurge_damage
    | Reload_effect
    | Reload_cooldown
      -- Wizard. These are also treated as "traits", not stats
    | ICE_CRIT_PERCENT_CHANCE
    | ICE_CRIT_DAMAGE_PERCENT
    | ICE_ADDITIONAL_PERCENT_DAMAGE
    | LIGHTNING_ZAP_PERCENT_DAMAGE
    | LIGHTNING_CHAIN_PERCENT
    | LIGHTNING_ADDITIONAL_PERCENT_DAMAGE
    | FIRE_CORROSION_PERCENT_DAMAGE_INCREASE
    | FIRE_BURN_PERCENT_DAMAGE_INCREASE
    | FIRE_ADDITIONAL_PERCENT_DAMAGE
    | LIGHTNING_CRIT_PERCENT_CHANCE
    | ICE_CHAIN_CHANCE_PERCENT
    | FIRE_ZAP_PERCENT_DAMAGE
    | LIGHTNING_BURN_PERCENT_DAMAGE_INCREASE
    | ICE_CORROSION_PERCENT_DAMAGE_INCREASE
    | FIRE_CRIT_DAMAGE_PERCENT
    | ICE_COOL_CRITICALS_CRIT_CHANCE_PERCENT
    | ICE_COOL_CRITICALS_DURATION_SECONDS
    | ICE_CHILLY_COOL_CRITICALS_CRIT_CHANCE_PERCENT
    | ICE_COLD_COOL_CRITICALS_DURATION_SECONDS
    | LIGHTNING_FLASH_SPEED_INCREASE_PERCENT
    | LIGHTNING_FLASH_NUM_SPELLS
    | LIGHTNING_FLASHIER_FLASH_HASTE_PERCENT
    | LIGHTNING_LINGERING_FLASH_NUM_SPELLS
    | FIRE_COMBUSTION_CHANCE_PERCENT
    | FIRE_COMBUSTION_DURATION_SECONDS
    | FIRE_INCENDIARY_COMBUSTION_CHANCE_PERCENT
    | FIRE_SEETHING_COMBUSTION_DURATION_SECONDS
    | FIRE_EXPLOSION_DAMAGE_PERCENT
    | LIGHTNING_CIRCUIT_DAMAGE_PERCENT
    | SHATTER_DAMAGE_PERCENT
    | SHATTER_NUM_MONSTERS
    | ICE_COST_REDUCTION_PERCENT_PER_LEVEL
    | LIGHTNING_COST_REDUCTION_PERCENT_PER_LEVEL
    | FIRE_COST_REDUCTION_PERCENT_PER_LEVEL
    | THUNDERSTORM_ACTIVATION_CHANCE_PER_RANK
    | THUNDERSTORM_DAMAGE_TRAIT
    | THUNDERSTORM_DURATION_TRAIT
    | HEAT_BURST_ACTIVATION_CHANCE_PER_RANK
    | HEAT_BURST_DAMAGE_TRAIT
    | HEAT_BURST_DURATION_TRAIT
    | COLD_FRONT_ACTIVATION_CHANCE_PER_RANK
    | COLD_FRONT_DAMAGE_TRAIT
    | COLD_FRONT_DURATION_TRAIT
    | ICE_LIGHTNING_SYMBIOSIS
    | FIRE_LIGHTNING_SYMBIOSIS
    | ICE_FIRE_SYMBIOSIS


statList : List Stat
statList =
    [ STAT_IDLE_GOLD
    , STAT_HASTE
    , STAT_GOLD
    , STAT_CRIT_DAMAGE
    , STAT_CRIT_CHANCE
    , STAT_TOTAL_ENERGY
    , STAT_TOTAL_MANA
    , STAT_BONUS_GOLD_CHANCE
    , STAT_ITEM_COST_REDUCTION
    , STAT_CLICK_DAMAGE
    , STAT_IDLE_DAMAGE
    , STAT_MOVEMENT_SPEED
    , STAT_PIERCE_CHANCE
    , STAT_MANA_REGEN
    , STAT_CLICKABLE_GOLD
    , STAT_TREASURE_CHEST_CHANCE
    , STAT_TREASURE_CHEST_GOLD
    , STAT_BOSS_GOLD
    , STAT_CLICKABLE_CHANCE
    , STAT_ENERGY_REGEN
    , STAT_DAMAGE
    , STAT_ENERGY_COST_REDUCTION
    , STAT_ITEM_WEAPON_DAMAGE
    , STAT_ITEM_HEAD_DAMAGE
    , STAT_ITEM_CHEST_DAMAGE
    , STAT_ITEM_RING_DAMAGE
    , STAT_ITEM_LEGS_DAMAGE
    , STAT_ITEM_HANDS_DAMAGE
    , STAT_ITEM_FEET_DAMAGE
    , STAT_ITEM_BACK_DAMAGE
    , STAT_AUTOMATOR_SPEED
    , STAT_AUTOATTACK_DAMAGE
    , MultiClick_stacks
    , MultiClick_energyCost
    , BigClicks_stacks
    , BigClicks_damage
    , HugeClick_damage
    , ManaCrit_damage
    , Clickstorm_cooldown
    , Energize_cooldown
    , Energize_manaCost
    , Energize_duration
    , Powersurge_cooldown
    , Powersurge_manaCost
    , Powersurge_duration
    , Powersurge_damage
    , Reload_effect
    , Reload_cooldown
    , ICE_CRIT_PERCENT_CHANCE
    , ICE_CRIT_DAMAGE_PERCENT
    , ICE_ADDITIONAL_PERCENT_DAMAGE
    , LIGHTNING_ZAP_PERCENT_DAMAGE
    , LIGHTNING_CHAIN_PERCENT
    , LIGHTNING_ADDITIONAL_PERCENT_DAMAGE
    , FIRE_CORROSION_PERCENT_DAMAGE_INCREASE
    , FIRE_BURN_PERCENT_DAMAGE_INCREASE
    , FIRE_ADDITIONAL_PERCENT_DAMAGE
    , LIGHTNING_CRIT_PERCENT_CHANCE
    , ICE_CHAIN_CHANCE_PERCENT
    , FIRE_ZAP_PERCENT_DAMAGE
    , LIGHTNING_BURN_PERCENT_DAMAGE_INCREASE
    , ICE_CORROSION_PERCENT_DAMAGE_INCREASE
    , FIRE_CRIT_DAMAGE_PERCENT
    , ICE_COOL_CRITICALS_CRIT_CHANCE_PERCENT
    , ICE_COOL_CRITICALS_DURATION_SECONDS
    , ICE_CHILLY_COOL_CRITICALS_CRIT_CHANCE_PERCENT
    , ICE_COLD_COOL_CRITICALS_DURATION_SECONDS
    , LIGHTNING_FLASH_SPEED_INCREASE_PERCENT
    , LIGHTNING_FLASH_NUM_SPELLS
    , LIGHTNING_FLASHIER_FLASH_HASTE_PERCENT
    , LIGHTNING_LINGERING_FLASH_NUM_SPELLS
    , FIRE_COMBUSTION_CHANCE_PERCENT
    , FIRE_COMBUSTION_DURATION_SECONDS
    , FIRE_INCENDIARY_COMBUSTION_CHANCE_PERCENT
    , FIRE_SEETHING_COMBUSTION_DURATION_SECONDS
    , FIRE_EXPLOSION_DAMAGE_PERCENT
    , LIGHTNING_CIRCUIT_DAMAGE_PERCENT
    , SHATTER_DAMAGE_PERCENT
    , SHATTER_NUM_MONSTERS
    , ICE_COST_REDUCTION_PERCENT_PER_LEVEL
    , LIGHTNING_COST_REDUCTION_PERCENT_PER_LEVEL
    , FIRE_COST_REDUCTION_PERCENT_PER_LEVEL
    , THUNDERSTORM_ACTIVATION_CHANCE_PER_RANK
    , THUNDERSTORM_DAMAGE_TRAIT
    , THUNDERSTORM_DURATION_TRAIT
    , HEAT_BURST_ACTIVATION_CHANCE_PER_RANK
    , HEAT_BURST_DAMAGE_TRAIT
    , HEAT_BURST_DURATION_TRAIT
    , COLD_FRONT_ACTIVATION_CHANCE_PER_RANK
    , COLD_FRONT_DAMAGE_TRAIT
    , COLD_FRONT_DURATION_TRAIT
    , ICE_LIGHTNING_SYMBIOSIS
    , FIRE_LIGHTNING_SYMBIOSIS
    , ICE_FIRE_SYMBIOSIS
    ]


statToString : Stat -> String
statToString stat =
    case stat of
        -- elm, usually I love you... but this really sucks
        STAT_IDLE_GOLD ->
            "STAT_IDLE_GOLD"

        STAT_HASTE ->
            "STAT_HASTE"

        STAT_GOLD ->
            "STAT_GOLD"

        STAT_CRIT_DAMAGE ->
            "STAT_CRIT_DAMAGE"

        STAT_CRIT_CHANCE ->
            "STAT_CRIT_CHANCE"

        STAT_TOTAL_ENERGY ->
            "STAT_TOTAL_ENERGY"

        STAT_TOTAL_MANA ->
            "STAT_TOTAL_MANA"

        STAT_BONUS_GOLD_CHANCE ->
            "STAT_BONUS_GOLD_CHANCE"

        STAT_ITEM_COST_REDUCTION ->
            "STAT_ITEM_COST_REDUCTION"

        STAT_CLICK_DAMAGE ->
            "STAT_CLICK_DAMAGE"

        STAT_IDLE_DAMAGE ->
            "STAT_IDLE_DAMAGE"

        STAT_MOVEMENT_SPEED ->
            "STAT_MOVEMENT_SPEED"

        STAT_PIERCE_CHANCE ->
            "STAT_PIERCE_CHANCE"

        STAT_MANA_REGEN ->
            "STAT_MANA_REGEN"

        STAT_CLICKABLE_GOLD ->
            "STAT_CLICKABLE_GOLD"

        STAT_TREASURE_CHEST_CHANCE ->
            "STAT_TREASURE_CHEST_CHANCE"

        STAT_TREASURE_CHEST_GOLD ->
            "STAT_TREASURE_CHEST_GOLD"

        STAT_BOSS_GOLD ->
            "STAT_BOSS_GOLD"

        STAT_CLICKABLE_CHANCE ->
            "STAT_CLICKABLE_CHANCE"

        STAT_ENERGY_REGEN ->
            "STAT_ENERGY_REGEN"

        STAT_DAMAGE ->
            "STAT_DAMAGE"

        STAT_ENERGY_COST_REDUCTION ->
            "STAT_ENERGY_COST_REDUCTION"

        STAT_ITEM_WEAPON_DAMAGE ->
            "STAT_ITEM_WEAPON_DAMAGE"

        STAT_ITEM_HEAD_DAMAGE ->
            "STAT_ITEM_HEAD_DAMAGE"

        STAT_ITEM_CHEST_DAMAGE ->
            "STAT_ITEM_CHEST_DAMAGE"

        STAT_ITEM_RING_DAMAGE ->
            "STAT_ITEM_RING_DAMAGE"

        STAT_ITEM_LEGS_DAMAGE ->
            "STAT_ITEM_LEGS_DAMAGE"

        STAT_ITEM_HANDS_DAMAGE ->
            "STAT_ITEM_HANDS_DAMAGE"

        STAT_ITEM_FEET_DAMAGE ->
            "STAT_ITEM_FEET_DAMAGE"

        STAT_ITEM_BACK_DAMAGE ->
            "STAT_ITEM_BACK_DAMAGE"

        STAT_AUTOMATOR_SPEED ->
            "STAT_AUTOMATOR_SPEED"

        STAT_AUTOATTACK_DAMAGE ->
            "STAT_AUTOATTACK_DAMAGE"

        MultiClick_stacks ->
            "MultiClick_stacks"

        MultiClick_energyCost ->
            "MultiClick_energyCost"

        BigClicks_stacks ->
            "BigClicks_stacks"

        BigClicks_damage ->
            "BigClicks_damage"

        HugeClick_damage ->
            "HugeClick_damage"

        ManaCrit_damage ->
            "ManaCrit_damage"

        Clickstorm_cooldown ->
            "Clickstorm_cooldown"

        Energize_cooldown ->
            "Energize_cooldown"

        Energize_manaCost ->
            "Energize_manaCost"

        Energize_duration ->
            "Energize_duration"

        Powersurge_cooldown ->
            "Powersurge_cooldown"

        Powersurge_manaCost ->
            "Powersurge_manaCost"

        Powersurge_duration ->
            "Powersurge_duration"

        Powersurge_damage ->
            "Powersurge_damage"

        Reload_effect ->
            "Reload_effect"

        Reload_cooldown ->
            "Reload_cooldown"

        ICE_CRIT_PERCENT_CHANCE ->
            "ICE_CRIT_PERCENT_CHANCE"

        ICE_CRIT_DAMAGE_PERCENT ->
            "ICE_CRIT_DAMAGE_PERCENT"

        ICE_ADDITIONAL_PERCENT_DAMAGE ->
            "ICE_ADDITIONAL_PERCENT_DAMAGE"

        LIGHTNING_ZAP_PERCENT_DAMAGE ->
            "LIGHTNING_ZAP_PERCENT_DAMAGE"

        LIGHTNING_CHAIN_PERCENT ->
            "LIGHTNING_CHAIN_PERCENT"

        LIGHTNING_ADDITIONAL_PERCENT_DAMAGE ->
            "LIGHTNING_ADDITIONAL_PERCENT_DAMAGE"

        FIRE_CORROSION_PERCENT_DAMAGE_INCREASE ->
            "FIRE_CORROSION_PERCENT_DAMAGE_INCREASE"

        FIRE_BURN_PERCENT_DAMAGE_INCREASE ->
            "FIRE_BURN_PERCENT_DAMAGE_INCREASE"

        FIRE_ADDITIONAL_PERCENT_DAMAGE ->
            "FIRE_ADDITIONAL_PERCENT_DAMAGE"

        LIGHTNING_CRIT_PERCENT_CHANCE ->
            "LIGHTNING_CRIT_PERCENT_CHANCE"

        ICE_CHAIN_CHANCE_PERCENT ->
            "ICE_CHAIN_CHANCE_PERCENT"

        FIRE_ZAP_PERCENT_DAMAGE ->
            "FIRE_ZAP_PERCENT_DAMAGE"

        LIGHTNING_BURN_PERCENT_DAMAGE_INCREASE ->
            "LIGHTNING_BURN_PERCENT_DAMAGE_INCREASE"

        ICE_CORROSION_PERCENT_DAMAGE_INCREASE ->
            "ICE_CORROSION_PERCENT_DAMAGE_INCREASE"

        FIRE_CRIT_DAMAGE_PERCENT ->
            "FIRE_CRIT_DAMAGE_PERCENT"

        ICE_COOL_CRITICALS_CRIT_CHANCE_PERCENT ->
            "ICE_COOL_CRITICALS_CRIT_CHANCE_PERCENT"

        ICE_COOL_CRITICALS_DURATION_SECONDS ->
            "ICE_COOL_CRITICALS_DURATION_SECONDS"

        ICE_CHILLY_COOL_CRITICALS_CRIT_CHANCE_PERCENT ->
            "ICE_CHILLY_COOL_CRITICALS_CRIT_CHANCE_PERCENT"

        ICE_COLD_COOL_CRITICALS_DURATION_SECONDS ->
            "ICE_COLD_COOL_CRITICALS_DURATION_SECONDS"

        LIGHTNING_FLASH_SPEED_INCREASE_PERCENT ->
            "LIGHTNING_FLASH_SPEED_INCREASE_PERCENT"

        LIGHTNING_FLASH_NUM_SPELLS ->
            "LIGHTNING_FLASH_NUM_SPELLS"

        LIGHTNING_FLASHIER_FLASH_HASTE_PERCENT ->
            "LIGHTNING_FLASHIER_FLASH_HASTE_PERCENT"

        LIGHTNING_LINGERING_FLASH_NUM_SPELLS ->
            "LIGHTNING_LINGERING_FLASH_NUM_SPELLS"

        FIRE_COMBUSTION_CHANCE_PERCENT ->
            "FIRE_COMBUSTION_CHANCE_PERCENT"

        FIRE_COMBUSTION_DURATION_SECONDS ->
            "FIRE_COMBUSTION_DURATION_SECONDS"

        FIRE_INCENDIARY_COMBUSTION_CHANCE_PERCENT ->
            "FIRE_INCENDIARY_COMBUSTION_CHANCE_PERCENT"

        FIRE_SEETHING_COMBUSTION_DURATION_SECONDS ->
            "FIRE_SEETHING_COMBUSTION_DURATION_SECONDS"

        FIRE_EXPLOSION_DAMAGE_PERCENT ->
            "FIRE_EXPLOSION_DAMAGE_PERCENT"

        LIGHTNING_CIRCUIT_DAMAGE_PERCENT ->
            "LIGHTNING_CIRCUIT_DAMAGE_PERCENT"

        SHATTER_DAMAGE_PERCENT ->
            "SHATTER_DAMAGE_PERCENT"

        SHATTER_NUM_MONSTERS ->
            "SHATTER_NUM_MONSTERS"

        ICE_COST_REDUCTION_PERCENT_PER_LEVEL ->
            "ICE_COST_REDUCTION_PERCENT_PER_LEVEL"

        LIGHTNING_COST_REDUCTION_PERCENT_PER_LEVEL ->
            "LIGHTNING_COST_REDUCTION_PERCENT_PER_LEVEL"

        FIRE_COST_REDUCTION_PERCENT_PER_LEVEL ->
            "FIRE_COST_REDUCTION_PERCENT_PER_LEVEL"

        THUNDERSTORM_ACTIVATION_CHANCE_PER_RANK ->
            "THUNDERSTORM_ACTIVATION_CHANCE_PER_RANK"

        THUNDERSTORM_DAMAGE_TRAIT ->
            "THUNDERSTORM_DAMAGE_TRAIT"

        THUNDERSTORM_DURATION_TRAIT ->
            "THUNDERSTORM_DURATION_TRAIT"

        HEAT_BURST_ACTIVATION_CHANCE_PER_RANK ->
            "HEAT_BURST_ACTIVATION_CHANCE_PER_RANK"

        HEAT_BURST_DAMAGE_TRAIT ->
            "HEAT_BURST_DAMAGE_TRAIT"

        HEAT_BURST_DURATION_TRAIT ->
            "HEAT_BURST_DURATION_TRAIT"

        COLD_FRONT_ACTIVATION_CHANCE_PER_RANK ->
            "COLD_FRONT_ACTIVATION_CHANCE_PER_RANK"

        COLD_FRONT_DAMAGE_TRAIT ->
            "COLD_FRONT_DAMAGE_TRAIT"

        COLD_FRONT_DURATION_TRAIT ->
            "COLD_FRONT_DURATION_TRAIT"

        ICE_LIGHTNING_SYMBIOSIS ->
            "ICE_LIGHTNING_SYMBIOSIS"

        FIRE_LIGHTNING_SYMBIOSIS ->
            "FIRE_LIGHTNING_SYMBIOSIS"

        ICE_FIRE_SYMBIOSIS ->
            "ICE_FIRE_SYMBIOSIS"


statsBySkill : Dict String (Dict String Stat)
statsBySkill =
    statList
        |> List.map
            (\s ->
                case statToString s |> String.split "_" of
                    [ skill, stat ] ->
                        Just ( skill, stat, s )

                    _ ->
                        Nothing
            )
        |> Maybe.Extra.values
        |> Dict.Extra.groupBy (\( skill, stat, id ) -> skill)
        |> Dict.map (always <| Dict.fromList << List.map (\( skill, stat, id ) -> ( stat, id )))


statDict : Dict String Stat
statDict =
    statList |> List.map (\s -> ( statToString s, s )) |> Dict.fromList


statTable : List StatTotal -> Stat -> Result String StatTotal
statTable stats =
    let
        dict : Dict String StatTotal
        dict =
            stats |> List.map (\s -> ( statToString s.stat, s )) |> Dict.fromList
    in
    if Dict.size dict /= List.length statList then
        always <| Err <| "statTable expects a complete list of stats. Expected " ++ String.fromInt (List.length statList) ++ ", got " ++ String.fromInt (Dict.size dict)

    else
        \stat ->
            Dict.get (statToString stat) dict
                |> Result.fromMaybe "statTable had a complete list of stats, but somehow dict.get missed one"


getStat : String -> Maybe Stat
getStat name =
    Dict.get name statDict
