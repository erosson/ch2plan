module Model.Dijkstra exposing (Result, dijkstra, selectPathToNode)

import Set as Set exposing (Set)
import Dict as Dict exposing (Dict)
import Maybe.Extra
import GameData as G


{-| Shortest path of nodes that connect this to the current build - that is, to a start-location-connected selected node.
-}
type alias Result =
    { distances : Dict G.NodeId Int, prevs : Dict G.NodeId G.NodeId }


dijkstra : Set G.NodeId -> G.Graph -> Set G.NodeId -> Result
dijkstra startNodes graph selected0 =
    let
        allNodes =
            Dict.keys graph.nodes

        startOrSelected =
            Set.union startNodes selected0

        -- no constant for this, Elm?
        infinity : Int
        infinity =
            1 / 0 |> floor

        distances0 : Dict G.NodeId Int
        distances0 =
            -- missing = infinity distance
            startNodes
                |> Set.toList
                |> List.map (\id -> ( id, 0 ))
                |> Dict.fromList

        pqueue0 =
            startNodes |> Set.toList

        -- TODO: use a real priority queue. I'm offline right now!
        pqueueSort : Dict G.NodeId Int -> List G.NodeId -> List G.NodeId
        pqueueSort distances =
            List.sortBy (\id -> Dict.get id distances |> Maybe.withDefault infinity)

        pqueueNext : List a -> a
        pqueueNext =
            List.head >> Maybe.Extra.unpack (\_ -> Debug.crash "dijkstra: empty pqueue (no start nodes?)") identity

        visitNeighbors : Result -> G.NodeId -> List G.NodeId -> Result
        visitNeighbors dp prevNode neighbors =
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
                        visitNeighbors dp1 prevNode (List.drop 1 neighbors)

        visitNode : Set G.NodeId -> Result -> List G.NodeId -> G.NodeId -> Result
        visitNode unvisited dp0 pqueue0 node =
            if Set.isEmpty unvisited then
                dp0
            else
                let
                    unvisitedNeighbors =
                        G.neighbors node graph |> Set.intersect unvisited |> Set.toList

                    dp =
                        visitNeighbors { distances = dp0.distances, prevs = dp0.prevs } node unvisitedNeighbors

                    pqueue =
                        pqueue0 ++ unvisitedNeighbors |> pqueueSort dp.distances
                in
                    visitNode (Set.remove node unvisited) dp (List.drop 1 pqueue) (pqueueNext pqueue)
    in
        visitNode (allNodes |> Set.fromList) { distances = distances0, prevs = Dict.empty } (List.drop 1 pqueue0) (pqueueNext pqueue0)



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
