module SaveFile exposing (EtherealItem, EtherealItemInventory, EtherealStat, SaveFile, decoder, sourceStat)

import Dict exposing (Dict)
import Json.Decode as D


type alias SaveFile =
    { hero : String
    , build : List String
    , etherealItemInventory : EtherealItemInventory
    }


type alias EtherealItemInventory =
    Dict String EtherealItem


type alias EtherealItem =
    { rarity : Int
    , iconId : Int
    , slot : Int

    -- , stats : List EtherealStat
    , mainStat : EtherealStat
    , uniqueStat : Maybe EtherealStat
    , id : String
    }


type alias EtherealStat =
    { calculatedExchangeRate : Float
    , calculatedValue : Float
    , gild : Int
    , id : String
    , key : String
    }


sourceStatIds : Dict String String
sourceStatIds =
    -- DEFAULT_UPGRADABLE_STATS in helpfulAdventurer.as3
    [ "Gold Received"
    , "Movement Speed"
    , "Crit Chance"
    , "Crit Damage"
    , "Haste"
    , "Mana Regen"
    , "Idle Damage"
    , "Clickable Gold"
    , "Click Damage"
    , "Treasure Chest Chance"
    , "Monster Gold"
    , "Item Cost Reduction"
    , "Total Mana"
    , "Total Energy"
    , "Clickable Chance"
    , "Bonus Gold Chance"
    , "Treasure Chest Gold"
    , "Pierce Chance"
    , "Weapon Damage"
    , "Helm Damage"
    , "Chest Damage"
    , "Ring Damage"
    , "Pants Damage"
    , "Gloves Damage"
    , "Feet Damage"
    , "Back Damage"
    ]
        |> List.indexedMap (\i -> Tuple.pair ("Id" ++ String.fromInt i))
        |> Dict.fromList


sourceStat : EtherealStat -> Maybe String
sourceStat { id } =
    if String.endsWith "ForSkillPoints" id then
        Just "SkillPoints"

    else
        case String.split "ForTraitLevelsOf" id of
            [ dest, src ] ->
                Just src

            _ ->
                case String.split "ForStatLevelsOf" id of
                    [ dest, src ] ->
                        Dict.get src sourceStatIds |> Maybe.withDefault src |> Just

                    _ ->
                        Nothing


decoder : D.Decoder SaveFile
decoder =
    D.field "status" D.string
        |> D.andThen
            (\status ->
                case status of
                    "success" ->
                        successDecoder

                    _ ->
                        D.field "error" D.string |> D.andThen D.fail
            )


successDecoder : D.Decoder SaveFile
successDecoder =
    D.map3 SaveFile
        (D.field "hero" D.string)
        (D.field "build" <| D.list D.string)
        (D.field "etherealItemInventory" inventoryDecoder
            -- support old versions with no eth items
            |> D.maybe
            |> D.map (Maybe.withDefault Dict.empty)
        )


inventoryDecoder : D.Decoder EtherealItemInventory
inventoryDecoder =
    itemDecoder
        |> D.dict
        |> D.map (Dict.map (\k v -> v k))


itemDecoder : D.Decoder (String -> EtherealItem)
itemDecoder =
    D.map5 EtherealItem
        (D.field "rarity" D.int)
        (D.field "iconId" D.int)
        (D.field "slot" D.int)
        -- (D.field "stats" (D.dict statDecoder |> D.map Dict.values))
        (D.at [ "stats", "0" ] statDecoder)
        (D.maybe <| D.at [ "stats", "1" ] statDecoder)


statDecoder : D.Decoder EtherealStat
statDecoder =
    D.map5 EtherealStat
        (D.field "calculatedExchangeRate" D.float)
        (D.field "calculatedValue" D.float)
        (D.field "gild" D.int)
        (D.field "id" D.string)
        (D.field "key" D.string)
