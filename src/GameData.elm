module GameData
    exposing
        ( GameData
        , GameVersionData
        , Character
        , Graph
        , Node
        , Edge
        , NodeId
        , NodeType
        , NodeQuality(..)
        , decoder
        , neighbors
        , latestVersionId
        , latestVersion
        , graphMinX
        , graphMinY
        , graphMaxX
        , graphMaxY
        , graphWidth
        , graphHeight
        )

import Json.Decode as D
import Json.Decode.Pipeline as P
import Dict as Dict exposing (Dict)
import Set as Set exposing (Set)
import Maybe.Extra
import GameData.Stats as GS


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
    { name : String
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
    case g.versionList |> List.reverse |> List.head of
        Nothing ->
            Debug.crash "no game version data, no tree-planner"

        Just v ->
            v


latestVersion : GameData -> GameVersionData
latestVersion g =
    case Dict.get (latestVersionId g) g.byVersion of
        Nothing ->
            Debug.crash "game version in versionList not in byVersion"

        Just s ->
            s


decoder : D.Decoder GameData
decoder =
    P.decode GameData
        |> P.required "versionList" (D.list D.string)
        |> P.required "byVersion" (D.dict gameVersionDecoder)


gameVersionDecoder : D.Decoder GameVersionData
gameVersionDecoder =
    let
        decoder : GS.Stats -> D.Decoder GameVersionData
        decoder stats =
            P.decode GameVersionData
                |> P.required "versionSlug" D.string
                |> P.custom (D.succeed stats)
                |> P.required "heroes" (heroesDecoder stats)
    in
        D.field "stats" GS.decoder
            |> D.andThen decoder


heroesDecoder : GS.Stats -> D.Decoder (Dict String Character)
heroesDecoder stats =
    --D.dict characterDecoder
    dictKeyDecoder (\name -> Dict.get name stats.characters |> characterDecoder)


dictKeyDecoder : (String -> D.Decoder a) -> D.Decoder (Dict String a)
dictKeyDecoder decoder =
    let
        decode : String -> D.Value -> D.Decoder ( String, a )
        decode key val =
            case D.decodeValue (decoder key) val of
                Ok ok ->
                    D.succeed ( key, ok )

                Err err ->
                    D.fail err
    in
        D.keyValuePairs D.value
            |> D.map (List.map (uncurry decode))
            |> D.andThen (List.foldr (D.map2 (::)) (D.succeed []))
            |> D.map Dict.fromList


characterDecoder : Maybe GS.Character -> D.Decoder Character
characterDecoder stats =
    P.decode Character
        |> P.required "name" D.string
        |> P.required "flavorName" D.string
        |> P.required "flavorClass" D.string
        |> P.required "flavor" D.string
        |> P.required "levelGraphNodeTypes" (nodeTypesDecoder stats)
        -- graph looks at two fields to construct one, so this looks a little weird
        |> P.custom
            (P.decode graph
                |> P.required "levelGraphNodeTypes" (nodeTypesDecoder stats)
                |> P.required "levelGraphObject" levelGraphObjectDecoder
            )


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
        Ok key ->
            D.succeed ( key, val )

        Err err ->
            D.fail <| "couldn't decode " ++ name ++ " dict key: " ++ err


levelGraphObjectDecoder : D.Decoder GraphSpec
levelGraphObjectDecoder =
    P.decode GraphSpec
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
    P.decode NodeSpec
        |> P.required "val" D.string
        |> P.required "x" D.int
        |> P.required "y" D.int


nodeTypeDecoder : Maybe GS.Character -> String -> D.Decoder (NodeQuality -> NodeType)
nodeTypeDecoder stats key =
    P.decode NodeType
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
                    Debug.crash <| "no such nodetype: " ++ n.val

        nodes =
            Dict.map getNode graphSpec.nodes

        getEdge ( a, b ) =
            -- TODO this should be a decoder or result
            case ( Dict.get a nodes, Dict.get b nodes ) of
                ( Just a, Just b ) ->
                    ( a, b )

                _ ->
                    Debug.crash <| "no such edge: " ++ toString ( a, b )

        edges =
            Dict.map (always getEdge) graphSpec.edges
    in
        { nodes = nodes
        , edges = edges
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
neighbors id { neighbors } =
    case Dict.get id neighbors of
        Just ids ->
            ids

        Nothing ->
            Debug.crash <| "neighbors for a nonexistant node: " ++ toString id


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
