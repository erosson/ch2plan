module GameData exposing (..)

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
    , graphSpec : GraphSpec
    , lastUpdatedVersion : String
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
    { edges : Dict Int Edge
    , nodes : Dict Int Node
    }


type alias Node =
    { id : Int, typeId : String, val : NodeType, x : Int, y : Int }


type alias Edge =
    ( Node, Node )


characterDecoder : D.Decoder Character
characterDecoder =
    P.decode Character
        |> P.required "name" D.string
        |> P.required "flavorName" D.string
        |> P.required "flavorClass" D.string
        |> P.required "flavor" D.string
        |> P.required "levelGraphNodeTypes" nodeTypesDecoder
        -- |> P.required "levelGraphObject" levelGraphObjectDecoder
        |> P.required "levelGraphObject" levelGraphObjectDecoder
        |> P.required "lastUpdatedVersion" D.string


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


graph : Character -> Graph
graph c =
    let
        getNode id n =
            -- TODO this should be a decoder or result
            case Dict.get n.val c.nodeTypes of
                Just val ->
                    { id = id, typeId = n.val, x = n.x, y = n.y, val = val }

                Nothing ->
                    Debug.crash <| "no such nodetype: " ++ n.val

        nodes =
            Dict.map getNode c.graphSpec.nodes

        getEdge ( a, b ) =
            -- TODO this should be a decoder or result
            case ( Dict.get a nodes, Dict.get b nodes ) of
                ( Just a, Just b ) ->
                    ( a, b )

                _ ->
                    Debug.crash <| "no such edge: " ++ toString ( a, b )

        edges =
            Dict.map (always getEdge) c.graphSpec.edges
    in
        { nodes = nodes, edges = edges }


type alias NodeId =
    Int


neighbors : NodeId -> Graph -> Set NodeId
neighbors id g =
    let
        neighbor : Edge -> Maybe NodeId
        neighbor ( a, b ) =
            if a.id == id then
                Just b.id
            else if b.id == id then
                Just a.id
            else
                Nothing
    in
        g.edges
            |> Dict.toList
            |> List.map (Tuple.second >> neighbor)
            |> Maybe.Extra.values
            |> Set.fromList


graphMinX : Graph -> Int
graphMinX =
    .nodes >> Dict.foldr (always <| .x >> min) 0


graphMinY : Graph -> Int
graphMinY =
    .nodes >> Dict.foldr (always <| .y >> min) 0


graphMaxX : Graph -> Int
graphMaxX =
    .nodes >> Dict.foldr (always <| .x >> max) 0


graphMaxY : Graph -> Int
graphMaxY =
    .nodes >> Dict.foldr (always <| .y >> max) 0


graphHeight : Graph -> Int
graphHeight g =
    graphMaxY g - graphMinY g


graphWidth : Graph -> Int
graphWidth g =
    graphMaxX g - graphMinX g
