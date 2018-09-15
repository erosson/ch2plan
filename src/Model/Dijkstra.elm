module Model.Dijkstra exposing (Result, dijkstra, empty, selectPathToNode)

import Dict as Dict exposing (Dict)
import GameData as G
import List.Extra
import Maybe.Extra
import Set as Set exposing (Set)


{-| Shortest path of nodes that connect this to the current build - that is, to a start-location-connected selected node.
-}
type alias Result =
    { distances : Dict G.NodeId Int, prevs : Dict G.NodeId G.NodeId }


empty : Result
empty =
    { distances = Dict.empty, prevs = Dict.empty }


infinity : Int
infinity =
    -- no constant for this, Elm?
    1 / 0 |> floor


dijkstra : G.Graph -> Set G.NodeId -> Maybe G.NodeId -> Result
dijkstra graph selected0 target =
    let
        allNodes =
            Dict.keys graph.nodes

        startOrSelected =
            Set.union graph.startNodes selected0

        distances0 : Dict G.NodeId Int
        distances0 =
            -- missing = infinity distance
            graph.startNodes
                |> Set.toList
                |> List.map (\id -> ( id, 0 ))
                |> Dict.fromList
    in
    visitNode 0 startOrSelected graph (allNodes |> Set.fromList) target { distances = distances0, prevs = Dict.empty }


{-| List.Extra.minimumBy, but quit early if the value reaches a certain threshold.

Useful when we gotta go fast and know the minimum won't go below a certain value.

-}
terminatingMinimumBy : comparable -> (a -> comparable) -> List a -> Maybe a
terminatingMinimumBy terminateAt fn items0 =
    let
        loop : List a -> a -> comparable -> a
        loop items minIn minOut =
            case items of
                [] ->
                    minIn

                headIn :: tail ->
                    let
                        headOut =
                            fn headIn
                    in
                    if headOut <= terminateAt then
                        headIn

                    else if headOut <= minOut then
                        loop tail headIn headOut

                    else
                        loop tail minIn minOut
    in
    case items0 of
        [] ->
            Nothing

        headIn :: tail ->
            Just <|
                let
                    headOut =
                        fn headIn
                in
                if headOut <= terminateAt then
                    headIn

                else
                    loop tail headIn headOut


visitNode : Int -> Set G.NodeId -> G.Graph -> Set G.NodeId -> Maybe G.NodeId -> Result -> Result
visitNode lastDistance startOrSelected graph unvisited target dp0 =
    -- the unvisited node with the minimum distance.
    -- A priority queue would be faster here, but it's dependant on distance -
    -- this is much simpler, requires no new dependencies, and fast enough.
    --
    -- Dijkstra's guarantees the distance of each visited node never decreases,
    -- so we can use terminatingMinimumBy to quit early if this node has the same
    -- distance as the last one we visited.
    case unvisited |> Set.foldl (\id list -> Dict.get id dp0.distances |> Maybe.Extra.unwrap list (\d -> ( id, d ) :: list)) [] |> terminatingMinimumBy lastDistance Tuple.second of
        Nothing ->
            -- all nodes visited!
            dp0

        Just ( node, _ ) ->
            if Just node == target then
                -- if we're searching for this one specific node, quit early
                dp0

            else
                let
                    unvisitedNeighbors =
                        G.neighbors node graph |> Set.intersect unvisited |> Set.toList

                    d =
                        Dict.get node dp0.distances |> Maybe.Extra.unpack (\_ -> Debug.todo "dijkstra: visitNeighbors: no prevNode distance?") identity

                    dp =
                        visitNeighbors startOrSelected { distances = dp0.distances, prevs = dp0.prevs } node d unvisitedNeighbors
                in
                visitNode d startOrSelected graph (Set.remove node unvisited) target dp


visitNeighbors : Set G.NodeId -> Result -> G.NodeId -> Int -> List G.NodeId -> Result
visitNeighbors startOrSelected dp prevNode prevDist neighbors =
    case List.head neighbors of
        Nothing ->
            dp

        Just nextNode ->
            let
                { distances, prevs } =
                    dp

                d =
                    if prevDist == 0 && Set.member nextNode startOrSelected then
                        -- we still have a selected-connection to the start area; keep growing it
                        0

                    else
                        -- even if this node's selected, it's not start-connected
                        prevDist + 1

                isShorter =
                    d < (Dict.get nextNode distances |> Maybe.withDefault infinity)

                dp1 =
                    if isShorter then
                        { distances = Dict.insert nextNode d distances, prevs = Dict.insert nextNode prevNode prevs }

                    else
                        dp
            in
            visitNeighbors startOrSelected dp1 prevNode prevDist (List.drop 1 neighbors)



-- All nodes that will be selected to select this one, including this one.


selectPathToNode : Result -> G.NodeId -> List G.NodeId
selectPathToNode { prevs } =
    let
        loop path first =
            case Dict.get first prevs of
                Nothing ->
                    first :: path

                Just next ->
                    loop (first :: path) next
    in
    loop []
