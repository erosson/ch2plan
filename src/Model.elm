module Model exposing (..)

import Regex as Regex exposing (Regex)
import Set as Set exposing (Set)
import Dict as Dict exposing (Dict)
import Lazy as Lazy exposing (Lazy)
import Task
import Process
import Json.Decode as Decode
import Navigation
import Maybe.Extra
import List.Extra
import Math.Vector2 as V2
import Draggable
import GameData as G
import Route as Route exposing (Route)
import Model.Dijkstra as Dijkstra


type Msg
    = SearchInput String
    | SelectInput Int -- TODO should really remove this one in favor of links
    | NavLocation Navigation.Location
    | Preprocess
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
    | Home HomeModel
    | HomeError Route.HomeParams


type alias HomeModel =
    -- Data unique to the skill tree page. Lost when leaving the skill tree.
    -- Some of this is redundant with the plain route - for example,
    -- Route.HomeParams.build and HomeModel.selected contain the same information.
    -- This is deliberate - Elm does not have memoization (pure functional!)
    -- so this speeds things up a bit. Be careful when updating.
    { params : Route.HomeParams
    , search : Maybe Regex
    , zoom : Float
    , center : V2.Vec2
    , drag : Draggable.State ()
    , char : G.Character
    , selected : Set G.NodeId
    , dijkstra : Lazy Dijkstra.Result
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
            , preprocessCmd
            )

        Err err ->
            Debug.crash err


preprocessCmd : Cmd Msg
preprocessCmd =
    -- setTimeout to let the UI render, then run delayed calculations
    Process.sleep 1
        |> Task.andThen (always <| Task.succeed Preprocess)
        |> Task.perform identity


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
                    Home m

                Err _ ->
                    HomeError params


initHome : Route.HomeParams -> { m | characterData : Dict String G.Character } -> Result String HomeModel
initHome q { characterData } =
    case Dict.get q.hero characterData of
        Nothing ->
            Err <| "no such hero: " ++ q.hero

        Just char ->
            let
                selected =
                    buildToNodes startNodes char.graph q.build
            in
                Ok
                    { params = q
                    , search = Maybe.map (Regex.regex >> Regex.caseInsensitive) q.search
                    , zoom = 1
                    , center = V2.vec2 0 0
                    , drag = Draggable.init
                    , char = char
                    , selected = selected
                    , dijkstra = Lazy.lazy (\() -> Dijkstra.dijkstra startNodes char.graph selected Nothing)
                    }


invert : comparable -> Set comparable -> Set comparable
invert id set =
    if Set.member id set then
        Set.remove id set
    else
        Set.insert id set


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model.route of
        Home home ->
            case msg of
                SearchInput str ->
                    let
                        q =
                            home.params
                    in
                        case str of
                            "" ->
                                ( model, Navigation.modifyUrl <| Route.stringify <| Route.Home { q | search = Nothing } )

                            _ ->
                                ( model, Navigation.modifyUrl <| Route.stringify <| Route.Home { q | search = Just str } )

                SelectInput id ->
                    let
                        selected =
                            if model.features.multiSelect then
                                if Set.member id home.selected then
                                    -- remove the node, and any disconnected from the start by its removal
                                    home.selected
                                        |> invert id
                                        |> reachableSelectedNodes startNodes home.char.graph
                                else
                                    -- add the node and any in between
                                    Dijkstra.selectPathToNode (Lazy.force home.dijkstra) id
                                        |> Set.fromList
                                        |> Set.union home.selected
                            else
                                -- the old way - one node at a time. faster.
                                let
                                    s =
                                        invert id home.selected
                                in
                                    if isValidSelection startNodes home.char.graph s then
                                        s
                                    else
                                        home.selected

                        q =
                            home.params

                        route =
                            Route.Home { q | build = nodesToBuild home.char.graph selected }
                    in
                        ( model, Navigation.modifyUrl <| Route.stringify route )

                Preprocess ->
                    -- calculate dijkstra immediately after the view renders, so we have it ready later, when the user clicks.
                    -- It's not *that* slow - 200ms-ish - but that's slow enough to make a difference.
                    -- This makes things feel much more responsive.
                    --
                    -- Unlike most other things Elm, Lazy is *not* pure-functional. "let _ = ..." normally does nothing,
                    -- but here the side effect is pre-computing dijkstra!
                    let
                        _ =
                            if model.features.multiSelect then
                                Lazy.force home.dijkstra
                            else
                                Dijkstra.empty
                    in
                        ( model, Cmd.none )

                OnDragBy rawDelta ->
                    let
                        clampedCenter =
                            handleDrag home rawDelta home.zoom
                    in
                        ( { model | route = Home { home | center = clampedCenter } }, Cmd.none )

                Zoom factor ->
                    let
                        newZoom =
                            home.zoom
                                |> (+) (-factor * 0.025)
                                |> clamp 1 5

                        newCenter =
                            handleDrag home (V2.vec2 0 0) newZoom
                    in
                        ( { model | route = Home { home | zoom = newZoom, center = newCenter } }, Cmd.none )

                DragMsg dragMsg ->
                    Draggable.update dragConfig dragMsg home
                        |> Tuple.mapFirst (\home2 -> { model | route = Home home2 })

                NavLocation loc ->
                    case Route.parse loc |> routeToModel model of
                        Home home2 ->
                            -- preserve non-url state, like zoom/pan
                            ( { model
                                | route =
                                    Home
                                        { home
                                            | params = home2.params
                                            , search = home2.search
                                            , char = home2.char
                                            , selected = home2.selected
                                            , dijkstra = home2.dijkstra
                                        }
                                , features = Route.parseFeatures loc
                              }
                              -- compute dijkstra's after the view renders
                            , preprocessCmd
                            )

                        route ->
                            ( { model | route = route, features = Route.parseFeatures loc }, Cmd.none )

        _ ->
            -- all other routes have no state to preserve or update
            case msg of
                NavLocation loc ->
                    ( { model | route = Route.parse loc |> routeToModel model, features = Route.parseFeatures loc }, Cmd.none )

                _ ->
                    ( model, Cmd.none )


handleDrag : HomeModel -> V2.Vec2 -> Float -> V2.Vec2
handleDrag home delta zoom =
    let
        g =
            home.char.graph

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
summary { char, selected } =
    char.graph.nodes
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
        Home home ->
            Draggable.subscriptions DragMsg home.drag

        _ ->
            Sub.none


dragConfig : Draggable.Config () Msg
dragConfig =
    Draggable.basicConfig (OnDragBy << V2.fromTuple)
