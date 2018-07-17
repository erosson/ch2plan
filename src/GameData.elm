module GameData exposing (..)

import Json.Decode as D
import Json.Decode.Pipeline as P
import Dict as Dict exposing (Dict)
import Maybe.Extra


type alias Character =
    { name : String
    , flavorName : String
    , flavorClass : String
    , flavor : String
    , levelGraphObject : LevelGraphObject
    , levelGraphNodeTypes : Dict String NodeType
    }


type alias LevelGraphObject =
    { edges : Dict Int Edge
    , nodes : Dict Int Node
    }


type alias Edge =
    ( Int, Int )


type alias Node =
    { val : String, x : Int, y : Int }


type alias NodeType =
    { name : String, tooltip : Maybe String }


characterDecoder : D.Decoder Character
characterDecoder =
    P.decode Character
        |> P.required "name" D.string
        |> P.required "flavorName" D.string
        |> P.required "flavorClass" D.string
        |> P.required "flavor" D.string
        |> P.required "levelGraphObject" levelGraphObjectDecoder
        |> P.required "levelGraphNodeTypes" (nodeTypeDecoder |> D.dict)


decodeDictKeyInt name ( key0, val ) =
    case String.toInt key0 of
        Ok key ->
            D.succeed ( key, val )

        Err err ->
            D.fail <| "couldn't decode " ++ name ++ " dict key: " ++ err


levelGraphObjectDecoder : D.Decoder LevelGraphObject
levelGraphObjectDecoder =
    P.decode LevelGraphObject
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


edgeDecoder : D.Decoder Edge
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


nodeDecoder : D.Decoder Node
nodeDecoder =
    P.decode Node
        |> P.required "val" D.string
        |> P.required "x" D.int
        |> P.required "y" D.int


nodeTypeDecoder : D.Decoder NodeType
nodeTypeDecoder =
    P.decode NodeType
        |> P.required "name" D.string
        |> P.optional "tooltip" (D.nullable D.string) Nothing
