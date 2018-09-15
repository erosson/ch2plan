module GameData exposing
    ( Character
    , Edge
    , GameData
    , GameVersionData
    , Graph
    , Node
    , NodeId
    , NodeQuality(..)
    , NodeType
    , Skill
    , decoder
    , graphHeight
    , graphMaxX
    , graphMaxY
    , graphMinX
    , graphMinY
    , graphWidth
    , latestVersion
    , latestVersionId
    , neighbors
    , nodeTypeToString
    , qualityToString
    )

import Dict as Dict exposing (Dict)
import GameData.Stats as GS
import Json.Decode as D
import Json.Decode.Pipeline as P
import Maybe.Extra
import Regex as Regex exposing (Regex)
import Set as Set exposing (Set)


type alias GameData =
    { versionList : List String
    , byVersion : Dict String GameVersionData
    }


type alias GameVersionData =
    { versionSlug : String
    , stats : GS.Stats
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
    , icon : String
    , tooltip : Maybe String
    , flavorText : Maybe String
    , stats : List ( GS.Stat, Int )
    , quality : NodeQuality
    }


type NodeQuality
    = Plain
    | Notable
    | Keystone


type alias NodeTypes =
    Dict String NodeType


type alias Graph =
    { edges : Dict NodeId Edge
    , nodes : Dict NodeId Node
    , startNodes : Set NodeId

    -- precalculated/derived from edges/nodes
    , bounds : GraphBounds
    , neighbors : Dict NodeId (Set NodeId)
    }


type alias Node =
    { id : Int, typeId : String, val : NodeType, x : Int, y : Int }


type alias Edge =
    ( Node, Node )


latestVersionId : GameData -> String
latestVersionId g =
    case g.versionList |> List.filter (String.contains "PTR" >> not) |> List.reverse |> List.head of
        Nothing ->
            Debug.todo "no game version data, no tree-planner"

        Just v ->
            v


latestVersion : GameData -> GameVersionData
latestVersion g =
    case Dict.get (latestVersionId g) g.byVersion of
        Nothing ->
            Debug.todo "game version in versionList not in byVersion"

        Just s ->
            s


decoder : D.Decoder GameData
decoder =
    D.succeed GameData
        |> P.required "versionList" (D.list D.string)
        |> P.required "byVersion" (D.dict gameVersionDecoder)


gameVersionDecoder : D.Decoder GameVersionData
gameVersionDecoder =
    let
        decoder_ : ( GS.Stats, Dict String Skill ) -> D.Decoder GameVersionData
        decoder_ ( stats, skills ) =
            D.succeed GameVersionData
                |> P.required "versionSlug" D.string
                |> P.custom (D.succeed stats)
                |> P.required "heroes" (heroesDecoder stats skills)
    in
    D.map2 (\a b -> ( a, b ))
        (D.field "stats" GS.decoder)
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


heroesDecoder : GS.Stats -> Dict String Skill -> D.Decoder (Dict String Character)
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
                    -- TODO elm 0.19 upgrade mangled the typing here a bit; fix it
                    D.fail (Debug.toString err)
    in
    D.keyValuePairs D.value
        |> D.map (List.map (\( a, b ) -> decode a b))
        |> D.andThen (List.foldr (D.map2 (::)) (D.succeed []))
        |> D.map Dict.fromList


characterDecoder : Dict String Skill -> Maybe GS.Character -> D.Decoder Character
characterDecoder skills stats =
    D.succeed Character
        |> P.required "name" D.string
        |> P.required "flavorName" D.string
        |> P.required "flavorClass" D.string
        |> P.required "flavor" D.string
        |> P.required "levelGraphNodeTypes" (nodeTypesDecoder stats)
        -- graph looks at two fields to construct one, so this looks a little weird
        |> P.custom
            (D.succeed graph
                |> P.required "levelGraphNodeTypes" (nodeTypesDecoder stats)
                |> P.required "levelGraphObject" levelGraphObjectDecoder
            )
        |> P.custom (D.succeed skills)


parseNodeQuality : String -> NodeQuality
parseNodeQuality id =
    -- This is a terribly hacky way to determine a node's color, but it works for now.
    if String.startsWith "q" id then
        Notable

    else if String.startsWith "Q" id then
        Keystone

    else
        Plain


nodeTypesDecoder : Maybe GS.Character -> D.Decoder NodeTypes
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


nodeTypeDecoder : Maybe GS.Character -> String -> D.Decoder (NodeQuality -> NodeType)
nodeTypeDecoder stats key =
    D.succeed NodeType
        |> P.custom (D.succeed key)
        |> P.required "name" D.string
        |> P.required "icon" D.string
        |> P.optional "tooltip" (D.nullable D.string) Nothing
        |> P.optional "flavorText" (D.nullable D.string) Nothing
        |> P.custom (Maybe.andThen (.stats >> Dict.get key) stats |> Maybe.withDefault [] |> D.succeed)



-- |> P.optional "icon" (D.nullable D.string) Nothing


graph : NodeTypes -> GraphSpec -> Graph
graph nodeTypes graphSpec =
    let
        getNode id n =
            -- TODO this should be a decoder or result
            case Dict.get n.val nodeTypes of
                Just val ->
                    { id = id, typeId = n.val, x = n.x, y = n.y, val = val }

                Nothing ->
                    Debug.todo <| "no such nodetype: " ++ n.val

        nodes =
            Dict.map getNode graphSpec.nodes

        getEdge ( a, b ) =
            -- TODO this should be a decoder or result
            case ( Dict.get a nodes, Dict.get b nodes ) of
                ( Just aa, Just bb ) ->
                    ( aa, bb )

                _ ->
                    Debug.todo <| "no such edge: " ++ Debug.toString ( a, b )

        edges =
            Dict.map (always getEdge) graphSpec.edges
    in
    { nodes = nodes
    , edges = edges
    , startNodes = Set.singleton 1 -- TODO happens to work for helpfulAdventurer, but where does this come from?
    , neighbors = calcNeighbors <| Dict.values edges
    , bounds = calcBounds <| Dict.values nodes
    }


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
    case Dict.get id g.neighbors of
        Just ids ->
            ids

        Nothing ->
            Debug.todo <| "neighbors for a nonexistant node: " ++ String.fromInt id


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
qualityToString =
    Debug.toString


nodeTypeToString : NodeType -> String
nodeTypeToString =
    Debug.toString
