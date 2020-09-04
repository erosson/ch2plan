module GameData exposing
    ( Character
    , Edge
    , Fatigue
    , FatigueId(..)
    , GameData
    , GameVersionData
    , Graph
    , Node
    , NodeId
    , NodeQuality(..)
    , NodeType
    , Skill
    , Spell
    , TranscensionPerk
    , decoder
    , fatigue
    , fatigues
    , graphHeight
    , graphMaxX
    , graphMaxY
    , graphMinX
    , graphMinY
    , graphWidth
    , latestVersion
    , latestVersionId
    , neighbors
    , qualityToString
    , spellFatigue
    , startNodes
    , tooltip
    , tooltipPlaceholder
    , wizardSpells
    )

import Dict exposing (Dict)
import Dict.Extra
import GameData.Stats as Stats exposing (Stat, StatTotal, Stats)
import Json.Decode as D
import Json.Decode.Pipeline as P
import Maybe.Extra
import Regex exposing (Regex)
import Set exposing (Set)


type alias GameData =
    { versionList : List String
    , byVersion : Dict String GameVersionData
    }


type alias GameVersionData =
    { versionSlug : String
    , stats : Stats
    , heroes : Dict String Character
    }


type alias Character =
    { name : String
    , flavorName : String
    , flavorClass : String
    , flavor : String
    , nodeTypes : NodeTypes
    , graph : Graph
    , skills : Dict String Skill
    , spells : List Spell
    , transcensionPerks : Dict Int TranscensionPerk
    }


type alias Skill =
    { id : String
    , name : String
    , iconId : Int
    , char : String
    , manaCost : Maybe Int
    , energyCost : Maybe Int
    , cooldown : Maybe Int
    }


type alias Spell =
    { id : String
    , rank : Int
    , types : Set Int
    , runeCombination : List Int
    , spellRings : List String
    , damageMultiplier : Float
    , costMultiplier : Float
    , msecsPerRune : Int
    , spellPanelIcon : String
    , displayName : String
    , description : String
    , tier : Int
    , manaCost : Int
    }


type alias GraphSpec =
    { edges : Dict Int EdgeSpec
    , nodes : Dict Int NodeSpec
    }


type alias EdgeSpec =
    ( Int, Int )


type alias NodeSpec =
    { val : String, x : Int, y : Int }


type alias NodeType =
    { key : String
    , name : String
    , icon : Maybe String
    , newTooltip : Maybe String
    , oldTooltip : Maybe String
    , flavorText : Maybe String
    , alwaysAvailable : Bool
    , flammable : Bool
    , stats : List ( Stat, Int )
    , quality : NodeQuality
    }


type alias TranscensionPerk =
    { name : String
    , maxLevel : Maybe Int
    , icon : String
    , description : String
    }


tooltip_ : NodeType -> Maybe String
tooltip_ node =
    node.newTooltip |> Maybe.map Just |> Maybe.withDefault node.oldTooltip


tooltip : NodeType -> String -> String
tooltip node default =
    tooltip_ node |> Maybe.withDefault default


{-| Find the stat-value placeholders in tooltip text. Replace them with ${VALUE}.

This is incredibly hacky and surely has bugs. The as3 constructs tooltips from a
function that we can't export. This is the best I've got for version 1.

-}
tooltipPlaceholder : NodeType -> Maybe String
tooltipPlaceholder node =
    Maybe.map
        (\raw ->
            if List.isEmpty node.stats then
                raw

            else
                let
                    rex1 =
                        Regex.fromString "\\d+(\\.\\d+)?%" |> Maybe.withDefault Regex.never

                    try1 =
                        raw |> Regex.replaceAtMost (List.length node.stats) rex1 (always "${VALUE%}")

                    rex2 =
                        Regex.fromString "\\d+(\\.\\d+)?" |> Maybe.withDefault Regex.never

                    try2 =
                        raw |> Regex.replaceAtMost (List.length node.stats) rex2 (always "${VALUE}")
                in
                -- Try replacing percentage-numbers, then non-percentage-numbers.
                -- This seems to work for most things, except reload nodes.
                -- TODO: how to substitute wizard's two-element tooltips?
                if try1 /= raw && node.key /= "Ra" then
                    try1

                else
                    try2
        )
        (tooltip_ node)


type NodeQuality
    = Plain
    | Notable
    | Keystone


type alias NodeTypes =
    Dict String NodeType


type alias Graph =
    { edges : Dict NodeId Edge
    , nodes : Dict NodeId Node

    -- precalculated/derived from edges/nodes
    , bounds : GraphBounds
    , neighbors : Dict NodeId (Set NodeId)
    , nodesByType : Dict String (Set NodeId)
    }


type alias Node =
    { id : Int, typeId : String, x : Int, y : Int, val : NodeType }


type alias Edge =
    ( Node, Node )


type FatigueId
    = Fire
    | Ice
    | Lit


type alias Fatigue =
    { id : FatigueId, label : String, ord : Int }


fatigueIds : List FatigueId
fatigueIds =
    [ Fire, Ice, Lit ]


fatigue : FatigueId -> Fatigue
fatigue f =
    case f of
        Fire ->
            Fatigue f "Fire" 1

        Ice ->
            Fatigue f "Ice" 2

        Lit ->
            Fatigue f "Lit" 3


fatigues : List Fatigue
fatigues =
    fatigueIds |> List.map fatigue


spellFatigue : Spell -> List ( Fatigue, Int )
spellFatigue s =
    if s.rank <= 0 then
        []

    else
        fatigues
            |> List.filter (\f -> Set.member f.ord s.types)
            |> List.map (\f -> ( f, s.rank ))


latestVersionId : GameData -> Maybe String
latestVersionId g =
    g.versionList
        |> List.filter (Regex.contains (Regex.fromString "PTR|\\(e\\)" |> Maybe.withDefault Regex.never) >> not)
        |> List.reverse
        |> List.head


latestVersion : GameData -> Maybe GameVersionData
latestVersion g =
    latestVersionId g |> Maybe.andThen (\v -> Dict.get v g.byVersion)


decoder : D.Decoder GameData
decoder =
    D.succeed GameData
        |> P.required "versionList" (D.list D.string)
        |> P.required "byVersion" (D.dict gameVersionDecoder)


gameVersionDecoder : D.Decoder GameVersionData
gameVersionDecoder =
    let
        decoder_ : ( Stats, Dict String Skill ) -> D.Decoder GameVersionData
        decoder_ ( stats, skills ) =
            D.succeed GameVersionData
                |> P.required "versionSlug" D.string
                |> P.custom (D.succeed stats)
                |> P.required "heroes" (heroesDecoder stats skills)
    in
    D.map2 (\a b -> ( a, b ))
        (D.field "stats" Stats.decoder)
        (D.field "skills" (D.dict skillDecoder)
            -- when 0.052 was exported, I hadn't yet implemented skills, so they're missing
            |> D.maybe
            |> D.map (Maybe.withDefault Dict.empty)
        )
        |> D.andThen decoder_


nonzeroIntDecoder : D.Decoder (Maybe Int)
nonzeroIntDecoder =
    D.int
        |> D.map
            (\i ->
                if i == 0 then
                    Nothing

                else
                    Just i
            )


skillNameToId : String -> String
skillNameToId =
    Regex.replace (Regex.fromString "\\W+" |> Maybe.withDefault Regex.never) (always "")


skillDecoder : D.Decoder Skill
skillDecoder =
    D.succeed Skill
        |> P.required "name" (D.string |> D.map skillNameToId)
        |> P.required "name" D.string
        |> P.required "iconId" D.int
        |> P.required "char" D.string
        |> P.required "manaCost" nonzeroIntDecoder
        |> P.required "energyCost" nonzeroIntDecoder
        |> P.required "cooldown" nonzeroIntDecoder


heroesDecoder : Stats -> Dict String Skill -> D.Decoder (Dict String Character)
heroesDecoder stats skills =
    --D.dict characterDecoder
    dictKeyDecoder (\name -> Dict.get name stats.characters |> characterDecoder (Dict.filter (\k v -> v.char == name) skills))


dictKeyDecoder : (String -> D.Decoder a) -> D.Decoder (Dict String a)
dictKeyDecoder decoder_ =
    let
        decode : String -> D.Value -> D.Decoder ( String, a )
        decode key val =
            case D.decodeValue (decoder_ key) val of
                Ok ok ->
                    D.succeed ( key, ok )

                Err err ->
                    D.fail (D.errorToString err)
    in
    D.keyValuePairs D.value
        |> D.map (List.map (\( a, b ) -> decode a b))
        |> D.andThen (List.foldr (D.map2 (::)) (D.succeed []))
        |> D.map Dict.fromList


characterDecoder : Dict String Skill -> Maybe Stats.Character -> D.Decoder Character
characterDecoder skills stats =
    D.succeed Character
        |> P.required "name" D.string
        |> P.required "flavorName" D.string
        |> P.required "flavorClass" D.string
        |> P.required "flavor" D.string
        |> P.required "levelGraphNodeTypes" (nodeTypesDecoder stats)
        -- graph looks at two fields to construct one, so this looks a little weird
        |> P.custom
            (D.map2 graphDecoder
                (D.field "levelGraphNodeTypes" (nodeTypesDecoder stats))
                (D.field "levelGraphObject" levelGraphObjectDecoder)
                |> D.andThen identity
            )
        |> P.custom (D.succeed skills)
        -- spells are for wizards - `spells=null` for cid
        -- spells weren't exported pre-0.12.0 - the field may be missing
        |> P.optional "spells"
            (D.list spellDecoder
                |> D.nullable
                |> D.map (Maybe.withDefault [])
            )
            []
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
        |> P.required "name" D.string
        |> P.required "maxLevel"
            (D.int
                |> D.map
                    (\i ->
                        if i < 0 then
                            Nothing

                        else
                            Just i
                    )
            )
        |> P.required "icon" D.string
        |> P.required "description" D.string


spellDecoder : D.Decoder Spell
spellDecoder =
    D.succeed Spell
        |> P.required "id" D.string
        |> P.required "rank" D.int
        |> P.required "types" (D.list D.int |> D.map Set.fromList)
        |> P.required "runeCombination" (D.list D.int)
        |> P.required "spellRings" (D.list D.string)
        |> P.required "damageMultiplier" D.float
        |> P.required "costMultiplier" D.float
        |> P.required "msecsPerRune" D.int
        |> P.required "spellPanelIcon" D.string
        |> P.required "displayName" D.string
        |> P.required "description" D.string
        |> P.required "tier" D.int
        |> P.required "manaCost" D.int


parseNodeQuality : String -> NodeQuality
parseNodeQuality id =
    -- This is a terribly hacky way to determine a node's color, but it works for now.
    if String.startsWith "q" id then
        Notable

    else if String.startsWith "Q" id then
        Keystone

    else
        Plain


nodeTypesDecoder : Maybe Stats.Character -> D.Decoder NodeTypes
nodeTypesDecoder stats =
    nodeTypeDecoder stats |> dictKeyDecoder |> D.map (Dict.map (\k -> \v -> v <| parseNodeQuality k))


decodeDictKeyInt name ( key0, val ) =
    case String.toInt key0 of
        Just key ->
            D.succeed ( key, val )

        Nothing ->
            D.fail <| "couldn't decode " ++ name ++ " dict key"


levelGraphObjectDecoder : D.Decoder GraphSpec
levelGraphObjectDecoder =
    D.succeed GraphSpec
        |> P.required "edges"
            (edgeDecoder
                |> D.dict
                |> D.andThen (Dict.toList >> List.head >> Maybe.Extra.unwrap (D.fail "couldn't decode levelGraphObject edge dict") D.succeed)
                |> D.andThen (decodeDictKeyInt "levelGraphObject edge")
                |> D.list
                |> D.map Dict.fromList
            )
        |> P.required "nodes"
            (nodeDecoder
                |> D.dict
                |> D.andThen (Dict.toList >> List.head >> Maybe.Extra.unwrap (D.fail "couldn't decode levelGraphObject node dict") D.succeed)
                |> D.andThen (decodeDictKeyInt "levelGraphObject node")
                |> D.list
                |> D.map Dict.fromList
            )


edgeDecoder : D.Decoder EdgeSpec
edgeDecoder =
    D.list D.int
        |> D.andThen
            (\list ->
                case list of
                    [ a, b ] ->
                        D.succeed ( a, b )

                    _ ->
                        D.fail "couldn't decode levelGraphObject edge value"
            )


nodeDecoder : D.Decoder NodeSpec
nodeDecoder =
    D.succeed NodeSpec
        |> P.required "val" D.string
        |> P.required "x" D.int
        |> P.required "y" D.int


nodeTypeDecoder : Maybe Stats.Character -> String -> D.Decoder (NodeQuality -> NodeType)
nodeTypeDecoder stats key =
    D.succeed NodeType
        |> P.custom (D.succeed key)
        |> P.required "name" D.string
        |> P.optional "icon" (D.nullable D.string) Nothing
        |> P.optional "__ch2plan_tooltip" (D.nullable D.string) Nothing
        |> P.optional "tooltip" (D.nullable D.string) Nothing
        |> P.optional "flavorText" (D.nullable D.string) Nothing
        |> P.optional "alwaysAvailable" D.bool False
        |> P.optional "flammable" D.bool False
        |> P.custom (Maybe.andThen (.stats >> Dict.get key) stats |> Maybe.withDefault [] |> D.succeed)



-- |> P.optional "icon" (D.nullable D.string) Nothing


graphDecoder : NodeTypes -> GraphSpec -> D.Decoder Graph
graphDecoder nodeTypes graphSpec =
    -- Construct nodes/edges by pairing with their nodeTypes
    let
        getNode id n =
            Dict.get n.val nodeTypes
                |> Maybe.map (Node id n.val n.x n.y)
                |> Result.fromMaybe ("no such node: " ++ String.fromInt id)
    in
    case graphSpec.nodes |> Dict.map getNode |> combineDict of
        Err ( k, err ) ->
            D.fail <| String.fromInt k ++ ": " ++ err

        Ok nodes ->
            let
                getEdge _ ( a, b ) =
                    case ( Dict.get a nodes, Dict.get b nodes ) of
                        ( Just aa, Just bb ) ->
                            Ok ( aa, bb )

                        _ ->
                            Err <| "no such edge: (" ++ String.fromInt a ++ ", " ++ String.fromInt b ++ ")"
            in
            case graphSpec.edges |> Dict.map getEdge |> combineDict of
                Err ( k, err ) ->
                    D.fail <| String.fromInt k ++ ": " ++ err

                Ok edges ->
                    D.succeed
                        { nodes = nodes
                        , edges = edges
                        , nodesByType =
                            nodes
                                |> Dict.values
                                |> Dict.Extra.groupBy .typeId
                                |> Dict.map (always (List.map .id >> Set.fromList))
                        , neighbors = Dict.values edges |> calcNeighbors
                        , bounds = Dict.values nodes |> calcBounds
                        }


combineDict : Dict comparable (Result e v) -> Result ( comparable, e ) (Dict comparable v)
combineDict =
    let
        fold k rv =
            Result.andThen
                (case rv of
                    Ok v ->
                        Dict.insert k v >> Ok

                    Err err ->
                        always (Err ( k, err ))
                )
    in
    Dict.foldl fold (Ok Dict.empty)


startNodes : Graph -> Set NodeId
startNodes =
    .nodes >> Dict.values >> List.filter (.val >> .alwaysAvailable) >> List.map .id >> Set.fromList


type alias NodeId =
    Int


calcNeighbors : List Edge -> Dict NodeId (Set NodeId)
calcNeighbors =
    -- precalculate all node neighbors. The graph is large and doesn't change.
    let
        update : NodeId -> Maybe (Set NodeId) -> Maybe (Set NodeId)
        update n2 =
            Maybe.withDefault Set.empty >> Set.insert n2 >> Just

        fold : Edge -> Dict NodeId (Set NodeId) -> Dict NodeId (Set NodeId)
        fold ( n1, n2 ) =
            Dict.update n1.id (update n2.id) >> Dict.update n2.id (update n1.id)
    in
    List.foldr fold Dict.empty


neighbors : NodeId -> Graph -> Set NodeId
neighbors id g =
    Dict.get id g.neighbors |> Maybe.withDefault Set.empty


type alias GraphBounds =
    { x : ( Int, Int ), y : ( Int, Int ) }


calcBounds : List Node -> GraphBounds
calcBounds nodes =
    -- precalculate x/y min/maxes. The graph is large and doesn't change.
    { x = ( List.foldr (.x >> min) 0 nodes, List.foldr (.x >> max) 0 nodes )
    , y = ( List.foldr (.y >> min) 0 nodes, List.foldr (.y >> max) 0 nodes )
    }


graphMinX : Graph -> Int
graphMinX =
    .bounds >> .x >> Tuple.first


graphMinY : Graph -> Int
graphMinY =
    .bounds >> .y >> Tuple.first


graphMaxX : Graph -> Int
graphMaxX =
    .bounds >> .x >> Tuple.second


graphMaxY : Graph -> Int
graphMaxY =
    .bounds >> .y >> Tuple.second


graphHeight : Graph -> Int
graphHeight g =
    graphMaxY g - graphMinY g


graphWidth : Graph -> Int
graphWidth g =
    graphMaxX g - graphMinX g


qualityToString : NodeQuality -> String
qualityToString q =
    case q of
        Plain ->
            "Plain"

        Notable ->
            "Notable"

        Keystone ->
            "Keystone"


characterByName : String -> GameData -> Maybe Character
characterByName char =
    latestVersion
        >> Maybe.andThen (\version -> Dict.get char version.heroes)


spells : Character -> Dict String Spell
spells =
    .spells >> Dict.Extra.fromListBy (.id >> String.toLower)


wizardSpells : GameData -> Maybe ( Character, Dict String Spell )
wizardSpells gameData =
    characterByName "wizard" gameData |> Maybe.map (\char -> ( char, spells char ))
