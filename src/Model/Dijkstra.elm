module Model.Dijkstra exposing (Result, dijkstra, selectPathToNode)

import Set as Set exposing (Set)
import Dict as Dict exposing (Dict)
import Maybe.Extra
import List.Extra
import GameData as G


{-| Shortest path of nodes that connect this to the current build - that is, to a start-location-connected selected node.
-}
type alias Result =
    { distances : Dict G.NodeId Int, prevs : Dict G.NodeId G.NodeId }


infinity : Int
infinity =
    -- no constant for this, Elm?
    1 / 0 |> floor


dijkstra : Set G.NodeId -> G.Graph -> Set G.NodeId -> Maybe G.NodeId -> Result
dijkstra startNodes graph selected0 target =
    let
        allNodes =
            Dict.keys graph.nodes

        startOrSelected =
            Set.union startNodes selected0

        distances0 : Dict G.NodeId Int
        distances0 =
            -- missing = infinity distance
            startNodes
                |> Set.toList
                |> List.map (\id -> ( id, 0 ))
                |> Dict.fromList
    in
        visitNode startOrSelected graph (allNodes |> Set.fromList) target { distances = distances0, prevs = Dict.empty }
            |> Debug.log "dijkstra"


visitNode : Set G.NodeId -> G.Graph -> Set G.NodeId -> Maybe G.NodeId -> Result -> Result
visitNode startOrSelected graph unvisited target dp0 =
    -- the unvisited node with the minimum distance.
    -- A priority queue would be faster here, but it's dependant on distance -
    -- this is much simpler, requires no new dependencies, and fast enough.
    case unvisited |> Set.foldl (\id list -> Dict.get id dp0.distances |> Maybe.Extra.unwrap list (\d -> ( id, d ) :: list)) [] |> List.Extra.minimumBy Tuple.second of
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

                    dp =
                        visitNeighbors startOrSelected { distances = dp0.distances, prevs = dp0.prevs } node unvisitedNeighbors
                in
                    visitNode startOrSelected graph (Set.remove node unvisited) target dp


visitNeighbors : Set G.NodeId -> Result -> G.NodeId -> List G.NodeId -> Result
visitNeighbors startOrSelected dp prevNode neighbors =
    case List.head neighbors of
        Nothing ->
            dp

        Just nextNode ->
            let
                { distances, prevs } =
                    dp

                dSource =
                    Dict.get prevNode distances |> Maybe.Extra.unpack (\_ -> Debug.crash "dijkstra: visitNeighbors: no prevNode distance?") identity

                d =
                    if dSource == 0 && Set.member nextNode startOrSelected then
                        -- we still have a selected-connection to the start area; keep growing it
                        0
                    else
                        -- even if this node's selected, it's not start-connected
                        dSource + 1

                isShorter =
                    d < (Dict.get nextNode distances |> Maybe.withDefault infinity)

                dp1 =
                    if isShorter then
                        { distances = Dict.insert nextNode d distances, prevs = Dict.insert nextNode prevNode prevs }
                    else
                        dp
            in
                visitNeighbors startOrSelected dp1 prevNode (List.drop 1 neighbors)



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
