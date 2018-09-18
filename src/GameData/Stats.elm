module GameData.Stats exposing
    ( Character
    , Growth(..)
    , Rules
    , Stat(..)
    , StatTotal
    , StatValue
    , Stats
    , calcStat
    , calcStats
    , decoder
    , getStat
    , statTable
    )

import Dict as Dict exposing (Dict)
import Dict.Extra
import Json.Decode as D
import Json.Decode.Pipeline as P
import List.Extra
import Maybe.Extra


type Growth
    = ExponentialMultiplier
    | Linear


type alias StatValue =
    { base : Float, growth : Growth, factor : Float }


type alias Stats =
    { rules : Rules
    , statValueFunctions : Dict String StatValue
    , characters : Dict String Character
    }


type alias Character =
    { stats : Dict NodeType (List ( Stat, Int )) }


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
        -- TODO traits
        |> P.required "stats" (charStatsDecoder |> D.map charStatsByNodeType)


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
    D.dict <|
        D.list <|
            D.map2 (\a b -> ( a, b ))
                (D.index 0 D.string)
                (D.index 1 D.int)


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
        |> P.custom (D.index 2 D.float)


growthDecoder : D.Decoder Growth
growthDecoder =
    D.string
        |> D.andThen
            (\str ->
                case str of
                    "exponentialMultiplier" ->
                        D.succeed ExponentialMultiplier

                    "linear" ->
                        D.succeed Linear

                    _ ->
                        D.fail <| "unknown stat growth function: " ++ str
            )


calcStat : Stats -> Stat -> Int -> Float
calcStat stats stat level =
    case Dict.get (statToString stat) stats.statValueFunctions of
        Nothing ->
            Debug.todo <| "Impossible. Perhaps the stats.json is incomplete. " ++ Debug.toString stat

        Just statValue ->
            case statValue.growth of
                Linear ->
                    statValue.base + (statValue.factor * toFloat level)

                ExponentialMultiplier ->
                    statValue.base * (statValue.factor ^ toFloat level)


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


type Stat
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
      -- everything below is not defined as stats in-game, but it's convenient to calculate them as stats
      -- skill-stats. Not actually stats in the ch2 code, but it's convenient for me to treat them as stats
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
    ]


statToString : Stat -> String
statToString =
    -- TODO
    Debug.toString


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


statTable : List StatTotal -> Stat -> StatTotal
statTable stats =
    let
        dict : Dict String StatTotal
        dict =
            stats |> List.map (\s -> ( statToString s.stat, s )) |> Dict.fromList
    in
    -- it's a dict-measuring contest lolol
    if Dict.size dict /= List.length statList then
        Debug.todo ("statTable expects a complete list of stats. Expected " ++ String.fromInt (List.length statList) ++ ", got " ++ String.fromInt (Dict.size dict)) dict

    else
        \stat ->
            case Dict.get (statToString stat) dict of
                Nothing ->
                    Debug.todo "statTable had a complete list of stats, but somehow dict.get missed one" stat

                Just juststat ->
                    juststat


getStat : String -> Maybe Stat
getStat name =
    Dict.get name statDict
