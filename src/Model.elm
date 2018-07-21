module Model exposing (..)

import Char
import Set as Set exposing (Set)
import Dict as Dict exposing (Dict)
import Json.Decode as Decode
import Navigation
import Maybe.Extra
import List.Extra
import Math.Vector2 as V2
import Draggable
import GameData as G
import Route as Route exposing (Route)


type Msg
    = SearchInput String
    | SelectInput Int -- TODO should really remove this one in favor of links
    | NavLocation Navigation.Location
    | NavRoute Route Route.Features
    | OnDragBy V2.Vec2
    | DragMsg (Draggable.Msg ())
    | Zoom Float


type alias Model =
    { changelog : String
    , lastUpdatedVersion : String
    , characterData : Dict String G.Character
    , route : RouteModel
    , features : Route.Features
    }


type RouteModel
    = NotFound
    | Changelog
    | Home Route.HomeParams HomeModel
    | HomeError Route.HomeParams


type alias HomeModel =
    { search : Maybe String
    , zoom : Float
    , center : V2.Vec2
    , drag : Draggable.State ()
    , char : G.Character
    , graph : G.Graph
    , selected : Set G.NodeId
    }


type alias Flags =
    { characterData : Decode.Value
    , lastUpdatedVersion : String
    , changelog : String
    }


init : Flags -> Navigation.Location -> ( Model, Cmd Msg )
init flags loc =
    case Decode.decodeValue G.decoder flags.characterData of
        Ok chars ->
            ( { changelog = flags.changelog
              , lastUpdatedVersion = flags.lastUpdatedVersion
              , characterData = chars
              , route = Changelog -- placeholder
              , features = Route.parseFeatures loc
              }
                |> \model -> { model | route = Route.parse loc |> routeToModel model }
            , Cmd.none
            )

        Err err ->
            Debug.crash err


routeToModel : Model -> Route -> RouteModel
routeToModel model route =
    case route of
        Route.Changelog ->
            Changelog

        Route.NotFound ->
            NotFound

        Route.Home params ->
            case initHome params model of
                Ok m ->
                    Home params m

                Err _ ->
                    HomeError params


initHome : Route.HomeParams -> { m | characterData : Dict String G.Character } -> Result String HomeModel
initHome q { characterData } =
    case Dict.get q.hero characterData of
        Nothing ->
            Err <| "no such hero: " ++ q.hero

        Just char ->
            let
                g =
                    G.graph char
            in
                Ok
                    { search = Nothing
                    , zoom = 1
                    , center = V2.vec2 0 0
                    , drag = Draggable.init
                    , char = char
                    , graph = g
                    , selected = buildToNodes startNodes g q.build
                    }


invert : comparable -> Set comparable -> Set comparable
invert id set =
    if Set.member id set then
        Set.remove id set
    else
        Set.insert id set


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NavLocation loc ->
            ( { model | route = Route.parse loc |> routeToModel model, features = Route.parseFeatures loc }, Cmd.none )

        NavRoute route features ->
            ( { model | route = route |> routeToModel model, features = features }, Cmd.none )

        _ ->
            case model.route of
                Changelog ->
                    ( model, Cmd.none )

                NotFound ->
                    ( model, Cmd.none )

                HomeError _ ->
                    ( model, Cmd.none )

                Home q home ->
                    case msg of
                        SearchInput str ->
                            case str of
                                "" ->
                                    ( { model | route = Home q { home | search = Nothing } }, Cmd.none )

                                _ ->
                                    ( { model | route = Home q { home | search = Just str } }, Cmd.none )

                        SelectInput id ->
                            let
                                selected =
                                    if model.features.multiSelect then
                                        if Set.member id home.selected then
                                            -- remove the node, and any disconnected from the start by its removal
                                            home.selected
                                                |> invert id
                                                |> reachableSelectedNodes startNodes home.graph
                                        else
                                            -- add the node and any in between
                                            selectPathToNode (dijkstra startNodes home.graph home.selected) id
                                                |> Set.fromList
                                                |> Set.union home.selected
                                    else
                                        -- the old way - one node at a time. faster.
                                        let
                                            s =
                                                invert id home.selected
                                        in
                                            if isValidSelection startNodes home.graph s then
                                                s
                                            else
                                                home.selected

                                route =
                                    Route.Home { q | build = nodesToBuild home.graph selected }
                            in
                                ( model, Navigation.modifyUrl <| Route.stringify route )

                        OnDragBy rawDelta ->
                            let
                                clampedCenter =
                                    handleDrag home rawDelta home.zoom
                            in
                                ( { model | route = Home q { home | center = clampedCenter } }, Cmd.none )

                        Zoom factor ->
                            let
                                newZoom =
                                    home.zoom
                                        |> (+) (-factor * 0.025)
                                        |> clamp 1 5

                                newCenter =
                                    handleDrag home (V2.vec2 0 0) newZoom
                            in
                                ( { model | route = Home q { home | zoom = newZoom, center = newCenter } }, Cmd.none )

                        DragMsg dragMsg ->
                            Draggable.update dragConfig dragMsg home
                                |> Tuple.mapFirst (\home2 -> { model | route = Home q home2 })

                        NavRoute _ _ ->
                            Debug.crash "already did NavRoute"

                        NavLocation _ ->
                            Debug.crash "already did NavLocation"


handleDrag : HomeModel -> V2.Vec2 -> Float -> V2.Vec2
handleDrag home delta zoom =
    let
        g =
            home.graph

        --Similar to iconSize in ViewGraph (can't access it here)
        margin =
            30 * zoom

        ( graphMin, graphMax ) =
            ( V2.vec2 (toFloat (G.graphMinX g) - margin) (toFloat (G.graphMinY g) - margin), V2.vec2 (toFloat (G.graphMaxX g) + margin) (toFloat (G.graphMaxY g) + margin) )

        ( halfGraphWidth, halfGraphHeight ) =
            ( toFloat (G.graphWidth g) / 2, toFloat (G.graphHeight g) / 2 )

        halfZoomedGraph =
            V2.scale (1 / zoom) (V2.vec2 halfGraphWidth halfGraphHeight)
    in
        home.center
            |> V2.add delta
            |> v2Max (V2.add graphMin halfZoomedGraph)
            |> v2Min (V2.sub graphMax halfZoomedGraph)


v2Min : V2.Vec2 -> V2.Vec2 -> V2.Vec2
v2Min a b =
    let
        x =
            min (V2.getX a) (V2.getX b)

        y =
            min (V2.getY a) (V2.getY b)
    in
        V2.vec2 x y


v2Max : V2.Vec2 -> V2.Vec2 -> V2.Vec2
v2Max a b =
    let
        x =
            max (V2.getX a) (V2.getX b)

        y =
            max (V2.getY a) (V2.getY b)
    in
        V2.vec2 x y


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


summary : HomeModel -> List ( Int, G.NodeType )
summary { graph, selected } =
    graph.nodes
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
    case model.route of
        Home q home ->
            Draggable.subscriptions DragMsg home.drag

        _ ->
            Sub.none


dragConfig : Draggable.Config () Msg
dragConfig =
    Draggable.basicConfig (OnDragBy << V2.fromTuple)
