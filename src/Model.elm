module Model exposing (..)

import Char
import Set as Set exposing (Set)
import Dict as Dict exposing (Dict)
import Json.Decode as Decode
import Navigation
import Maybe.Extra
import List.Extra
import GameData as G
import Route as Route exposing (Route)


type Msg
    = SearchInput String
    | SelectInput Int -- TODO should really remove this one in favor of links
    | NavLocation Navigation.Location
    | NavRoute Route Route.Features


type alias Model =
    { characterData : G.Character
    , route : Route
    , features : Route.Features
    , search : Maybe String
    }


type alias Flags =
    { characterData : Decode.Value
    }


init : Flags -> Navigation.Location -> ( Model, Cmd Msg )
init flags loc =
    case Decode.decodeValue G.characterDecoder flags.characterData of
        Ok char ->
            ( { characterData = char
              , route = Route.parse loc
              , features = Route.parseFeatures loc
              , search = Nothing
              }
            , Cmd.none
            )

        Err err ->
            Debug.crash err


invert : comparable -> Set comparable -> Set comparable
invert id set =
    if Set.member id set then
        Set.remove id set
    else
        Set.insert id set


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SearchInput str ->
            case str of
                "" ->
                    ( { model | search = Nothing }, Cmd.none )

                _ ->
                    ( { model | search = Just str }, Cmd.none )

        SelectInput id ->
            let
                g =
                    G.graph model.characterData

                selected0 =
                    selectedNodes model

                selected =
                    if model.features.multiSelect then
                        if Set.member id selected0 then
                            -- remove the node, and any disconnected from the start by its removal
                            selected0
                                |> invert id
                                |> reachableSelectedNodes startNodes g
                        else
                            -- add the node and any in between
                            selectPathToNode (dijkstra startNodes g selected0) id
                                |> Set.fromList
                                |> Set.union selected0
                    else
                        -- the old way - one node at a time. faster.
                        let
                            s =
                                invert id <| selected0
                        in
                            if isValidSelection startNodes g s then
                                s
                            else
                                selected0

                _ =
                    ( nodesToBuild g selected, buildToNodes startNodes g (nodesToBuild g selected) ) |> Debug.log "build"

                route =
                    Route.Home { build = nodesToBuild g selected }
            in
                -- if isValidSelection startNodes g selected then
                -- else
                -- ( model, Cmd.none )
                ( model, Navigation.modifyUrl <| Route.stringify route )

        NavLocation loc ->
            ( { model | route = Route.parse loc, features = Route.parseFeatures loc }, Cmd.none )

        NavRoute route features ->
            ( { model | route = route, features = features }, Cmd.none )


startNodes : Set G.NodeId
startNodes =
    -- TODO is this defined in the actual data?
    Set.singleton 1


{-| Remove any selected nodes that can't be reached from the start location.
-}
reachableSelectedNodes : Set G.NodeId -> G.Graph -> Set G.NodeId -> Set G.NodeId
reachableSelectedNodes startNodes graph selected =
    let
        loop : G.NodeId -> { reachable : Set G.NodeId, tried : Set G.NodeId } -> { reachable : Set G.NodeId, tried : Set G.NodeId }
        loop id res =
            if Set.member id res.tried then
                res
            else
                let
                    -- loop with all selected immediate neighbors
                    nextIds =
                        G.neighbors id graph |> Set.intersect selected
                in
                    Set.foldr loop { tried = Set.insert id res.tried, reachable = Set.union res.reachable nextIds } nextIds

        startReachable =
            Set.intersect selected startNodes
    in
        Set.foldr loop { tried = Set.empty, reachable = startReachable } startReachable
            |> .reachable


{-| Shortest path of nodes that connect this to the current build - that is, to a start-location-connected selected node.
-}
type alias DijkstraResult =
    { distances : Dict G.NodeId Int, prevs : Dict G.NodeId G.NodeId }


dijkstra : Set G.NodeId -> G.Graph -> Set G.NodeId -> DijkstraResult
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

        visitNeighbors : DijkstraResult -> G.NodeId -> List G.NodeId -> DijkstraResult
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

        visitNode : Set G.NodeId -> DijkstraResult -> List G.NodeId -> G.NodeId -> DijkstraResult
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


selectPathToNode : DijkstraResult -> G.NodeId -> List G.NodeId
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


isValidSelection : Set G.NodeId -> G.Graph -> Set G.NodeId -> Bool
isValidSelection startNodes graph selected =
    reachableSelectedNodes startNodes graph selected == selected


selectableNodes : Set G.NodeId -> G.Graph -> Set G.NodeId -> Set G.NodeId
selectableNodes startNodes graph selected =
    Set.foldr (\id -> \res -> G.neighbors id graph |> Set.union res) startNodes selected
        |> \res -> Set.diff res selected


nodesToBuild : G.Graph -> Set G.NodeId -> Maybe String
nodesToBuild graph =
    Set.toList
        >> List.map nodeToString
        >> String.join "&"
        >> (\s ->
                if s == "" then
                    Nothing
                else
                    Just s
           )


nodeToString : G.NodeId -> String
nodeToString =
    -- Char.fromCode >> String.fromChar
    toString


buildToNodes : Set G.NodeId -> G.Graph -> Maybe String -> Set G.NodeId
buildToNodes startNodes graph =
    Maybe.withDefault ""
        >> String.split "&"
        >> List.map (String.toInt >> Result.toMaybe)
        >> \ids0 ->
            let
                ids =
                    ids0 |> Maybe.Extra.values |> Set.fromList
            in
                if List.length ids0 == Set.size ids && isValidSelection startNodes graph ids then
                    ids
                else
                    Set.empty


selectedNodes : Model -> Set G.NodeId
selectedNodes model =
    case model.route of
        Route.Home { build } ->
            buildToNodes startNodes (G.graph model.characterData) build


summary : Model -> List ( Int, G.NodeType )
summary model =
    let
        selected =
            selectedNodes model
    in
        G.graph model.characterData
            |> .nodes
            |> Dict.filter (\id nodeType -> Set.member id selected)
            |> Dict.values
            |> List.map .val
            |> List.sortBy .name
            |> List.Extra.group
            |> List.map (\g -> List.head g |> Maybe.map ((,) (List.length g)))
            |> Maybe.Extra.values
            |> List.sortBy
                (\( count, nodeType ) ->
                    -1
                        * (count
                            -- I really can't sort on a tuple, Elm? Sigh.
                            + case nodeType.quality of
                                G.Keystone ->
                                    1000000

                                G.Notable ->
                                    1000

                                G.Plain ->
                                    0
                          )
                )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
