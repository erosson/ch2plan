module GameData
    exposing
        ( Character
        , Graph
        , Node
        , Edge
        , NodeId
        , NodeType
        , NodeQuality(..)
        , neighbors
        , decoder
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


decoder : D.Decoder (Dict String Character)
decoder =
    D.dict characterDecoder


characterDecoder : D.Decoder Character
characterDecoder =
    P.decode Character
        |> P.required "name" D.string
        |> P.required "flavorName" D.string
        |> P.required "flavorClass" D.string
        |> P.required "flavor" D.string
        |> P.required "levelGraphNodeTypes" nodeTypesDecoder
        -- graph looks at two fields to construct one, so this looks a little weird
        |> P.custom
            (P.decode graph
                |> P.required "levelGraphNodeTypes" nodeTypesDecoder
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


nodeTypesDecoder : D.Decoder NodeTypes
nodeTypesDecoder =
    nodeTypeDecoder |> D.dict |> D.map (Dict.map (\k -> \v -> v <| parseNodeQuality k))


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


nodeTypeDecoder : D.Decoder (NodeQuality -> NodeType)
nodeTypeDecoder =
    P.decode NodeType
        |> P.required "name" D.string
        |> P.required "icon" D.string
        |> P.optional "tooltip" (D.nullable D.string) Nothing
        |> P.optional "flavorText" (D.nullable D.string) Nothing



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
