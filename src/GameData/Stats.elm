module GameData.Stats
    exposing
        ( Stats
        , StatValue
        , Growth(..)
        , Character
        , Stat(..)
        , StatTotal
        , decoder
        , calcStat
        , calcStats
        , statTable
        )

import Json.Decode as D
import Json.Decode.Pipeline as P
import Dict as Dict exposing (Dict)
import List.Extra
import Dict.Extra


type Growth
    = ExponentialMultiplier
    | Linear


type alias StatValue =
    { base : Float, growth : Growth, factor : Float }


type alias Stats =
    { statValueFunctions : Dict String StatValue
    , characters : Dict String Character
    }


type alias Character =
    { stats : Dict NodeType (List ( Stat, Int )) }


decoder : D.Decoder Stats
decoder =
    P.decode Stats
        |> P.required "statValueFunctions" (D.dict statValueDecoder)
        |> P.required "characters" (D.dict charDecoder)


charDecoder : D.Decoder Character
charDecoder =
    P.decode Character
        -- TODO traits
        |> P.required "stats" (charStatsDecoder |> D.map charStatsByNodeType)


type alias NodeType =
    String


type alias StatName =
    String


charStatsDecoder : D.Decoder (Dict StatName (List ( NodeType, Int )))
charStatsDecoder =
    D.dict <|
        D.list <|
            D.map2 (,)
                (D.index 0 D.string)
                (D.index 1 D.int)


charStatsByNodeType : Dict StatName (List ( NodeType, Int )) -> Dict NodeType (List ( Stat, Int ))
charStatsByNodeType =
    Dict.toList
        >> List.concatMap
            (\( statName, nodes ) ->
                let
                    stat =
                        case getStat statName of
                            Nothing ->
                                Debug.crash <| "character had a stat missing from the GameData/Stats enum: " ++ statName

                            Just s ->
                                s
                in
                    nodes |> List.map (\( node, levels ) -> ( node, ( stat, levels ) ))
            )
        >> Dict.Extra.groupBy Tuple.first
        >> Dict.map (always <| List.map Tuple.second)


statValueDecoder : D.Decoder StatValue
statValueDecoder =
    P.decode StatValue
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
    case Dict.get (toString stat) stats.statValueFunctions of
        Nothing ->
            Debug.crash <| "Impossible. Perhaps the stats.json is incomplete. " ++ toString stat

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
                |> Dict.Extra.groupBy (Tuple.first >> toString)
                |> Dict.map (List.map Tuple.second >> List.sum |> always)
    in
        statList
            |> List.map
                (\stat ->
                    ( stat
                    , Dict.get (toString stat) sums
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
      -- below are not defined as stats in-game, but it's convenient to calculate them as stats
    | ExtraMulticlicks
    | MulticlickCost
    | BigClicksStacks
    | BigClicksDamage
    | HugeClickDamage
    | ManaCritDamage


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
    , ExtraMulticlicks
    , MulticlickCost
    , BigClicksStacks
    , BigClicksDamage
    , HugeClickDamage
    , ManaCritDamage
    ]


statDict : Dict String Stat
statDict =
    statList |> List.map (\s -> ( toString s, s )) |> Dict.fromList


statTable : List StatTotal -> Stat -> StatTotal
statTable stats =
    let
        dict : Dict String StatTotal
        dict =
            stats |> List.map (\s -> ( toString s.stat, s )) |> Dict.fromList
    in
        -- it's a dict-measuring contest lolol
        if Dict.size dict /= List.length statList then
            Debug.crash ("statTable expects a complete list of stats. Expected " ++ toString (List.length statList) ++ ", got " ++ toString (Dict.size dict)) dict
        else
            \stat ->
                case Dict.get (toString stat) dict of
                    Nothing ->
                        Debug.crash "statTable had a complete list of stats, but somehow dict.get missed one" stat

                    Just stat ->
                        stat


getStat : String -> Maybe Stat
getStat name =
    Dict.get name statDict
