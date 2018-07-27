module Model exposing (..)

import Regex as Regex exposing (Regex)
import Set as Set exposing (Set)
import Dict as Dict exposing (Dict)
import Lazy as Lazy exposing (Lazy)
import Time as Time exposing (Time)
import Task
import Process
import Json.Decode as Decode
import Navigation
import Maybe.Extra
import List.Extra
import Math.Vector2 as V2
import Draggable
import Window
import GameData as G
import GameData.Stats as GS
import Route as Route exposing (Route)
import Model.Dijkstra as Dijkstra


type Msg
    = SearchInput String
    | SearchNav (Maybe String) (Maybe String)
    | SelectInput Int
    | NavLocation Navigation.Location
    | Preprocess
    | OnDragBy V2.Vec2
    | DragMsg (Draggable.Msg ())
    | Zoom Float
    | Tooltip (Maybe G.NodeId)
    | Resize Window.Size
    | ToggleSidebar


type alias Model =
    { changelog : String
    , lastUpdatedVersion : String
    , characterData : Dict String G.Character
    , statsData : GS.Stats
    , route : RouteModel
    , features : Route.Features
    , windowSize : Window.Size
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
    , searchPrev : Maybe String
    , searchString : Maybe String
    , search : Maybe Regex
    , zoom : Float
    , center : V2.Vec2
    , drag : Draggable.State ()
    , char : G.Character
    , selected : Set G.NodeId
    , dijkstra : Lazy Dijkstra.Result
    , tooltip : Maybe G.NodeId
    , sidebarOpen : Bool
    }


type alias Flags =
    { characterData : Decode.Value
    , statsData : Decode.Value
    , lastUpdatedVersion : String
    , changelog : String
    , windowSize : Window.Size
    }


init : Flags -> Navigation.Location -> ( Model, Cmd Msg )
init flags loc =
    case Decode.decodeValue GS.decoder flags.statsData of
        Ok stats ->
            case Decode.decodeValue (G.decoder stats) flags.characterData of
                Ok chars ->
                    ( { changelog = flags.changelog
                      , lastUpdatedVersion = flags.lastUpdatedVersion
                      , windowSize = flags.windowSize
                      , characterData = chars
                      , statsData = stats
                      , features = Route.parseFeatures loc
                      , route = Changelog -- placeholder, modified just below
                      }
                        |> \model -> { model | route = Route.parse loc |> routeToModel model }
                    , Cmd.batch [ preprocessCmd, Task.perform Resize Window.size ]
                    )

                Err err ->
                    Debug.crash err

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


invert : comparable -> Set comparable -> Set comparable
invert id set =
    if Set.member id set then
        Set.remove id set
    else
        Set.insert id set


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
                    , searchPrev = q.search
                    , searchString = q.search
                    , search = searchRegex q.search
                    , zoom = 1
                    , center = V2.vec2 0 0
                    , drag = Draggable.init
                    , char = char
                    , selected = selected
                    , dijkstra = Lazy.lazy (\() -> Dijkstra.dijkstra startNodes char.graph selected Nothing)
                    , tooltip = Nothing
                    , sidebarOpen = True
                    }


searchRegex : Maybe String -> Maybe Regex
searchRegex =
    Maybe.map (Regex.regex >> Regex.caseInsensitive)


navFromHome : Model -> HomeModel -> Route -> ( RouteModel, Cmd Msg )
navFromHome model old route =
    case route |> routeToModel model of
        Home new ->
            -- preserve non-url state, like zoom/pan
            ( { old
                | params = new.params
                , search = new.search
                , char = new.char
                , selected = new.selected
              }
                -- avoid needless recomputing, ex. on search
                |> (\h ->
                        if old.params.build == new.params.build then
                            h
                        else
                            { h | dijkstra = new.dijkstra }
                   )
                |> Home
              -- compute dijkstra's after the view renders
            , if old.params.build == new.params.build then
                Cmd.none
              else
                preprocessCmd
            )

        routeModel ->
            ( routeModel, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model.route of
        Home ({ params } as home) ->
            case msg of
                SearchInput search0 ->
                    let
                        search =
                            if search0 == "" then
                                Nothing
                            else
                                Just search0
                    in
                        -- update the model instantly, but delay the url change for a moment, to solve https://github.com/erosson/ch2plan/issues/31
                        ( { model | route = Home { home | searchPrev = home.searchString, searchString = search, search = searchRegex search } }
                        , Process.sleep (1 * Time.second) |> Task.perform (always <| SearchNav home.searchString search)
                        )

                SearchNav from to ->
                    ( model
                    , if home.searchPrev == from then
                        let
                            _ =
                                Debug.log "searchNav accepted" ( home.searchPrev, from, to )
                        in
                            { params | search = to } |> Route.Home |> Route.stringify |> Navigation.modifyUrl
                      else
                        -- they typed something since the delay, do not update the url
                        Cmd.none
                    )

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
                        ( model, Navigation.newUrl <| Route.stringify route )

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
                        delta =
                            rawDelta |> V2.scale (-1 / home.zoom)

                        center =
                            home.center |> V2.add delta |> clampCenter home.char.graph
                    in
                        ( { model | route = Home { home | center = center } }, Cmd.none )

                Zoom factor ->
                    let
                        newZoom =
                            home.zoom
                                |> (+) (-factor * 0.01)
                                |> clamp 0.2 3
                    in
                        ( { model | route = Home { home | zoom = newZoom } }, Cmd.none )

                DragMsg dragMsg ->
                    Draggable.update dragConfig dragMsg home
                        |> Tuple.mapFirst (\home2 -> { model | route = Home home2 })

                Tooltip node ->
                    ( { model | route = Home { home | tooltip = node } }, Cmd.none )

                NavLocation loc ->
                    let
                        ( route, cmd ) =
                            Route.parse loc |> navFromHome model home
                    in
                        ( { model | route = route, features = Route.parseFeatures loc }, cmd )

                Resize windowSize ->
                    ( { model | windowSize = windowSize |> Debug.log "resize" }, Cmd.none )

                ToggleSidebar ->
                    ( { model | route = Home { home | sidebarOpen = not home.sidebarOpen } }, Cmd.none )

        _ ->
            -- all other routes have no state to preserve or update
            case msg of
                NavLocation loc ->
                    ( { model | route = Route.parse loc |> routeToModel model, features = Route.parseFeatures loc }, Cmd.none )

                Resize windowSize ->
                    ( { model | windowSize = windowSize }, Cmd.none )

                _ ->
                    ( model, Cmd.none )


clampCenter : G.Graph -> V2.Vec2 -> V2.Vec2
clampCenter g =
    v2Clamp (graphMinXY g) (graphMaxXY g)


graphMinXY g =
    V2.vec2 (G.graphMinX g |> toFloat) (G.graphMinY g |> toFloat)


graphMaxXY g =
    V2.vec2 (G.graphMaxX g |> toFloat) (G.graphMaxY g |> toFloat)


v2Clamp : V2.Vec2 -> V2.Vec2 -> V2.Vec2 -> V2.Vec2
v2Clamp minV maxV v =
    let
        ( minX, minY ) =
            V2.toTuple minV

        ( maxX, maxY ) =
            V2.toTuple maxV

        ( x, y ) =
            V2.toTuple v
    in
        V2.vec2 (clamp minX maxX x) (clamp minY maxY y)


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


nodeSummary : HomeModel -> List ( Int, G.NodeType )
nodeSummary { char, selected } =
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


statsSummary : Model -> HomeModel -> List GS.StatTotal
statsSummary { statsData } home =
    home
        |> nodeSummary
        |> List.concatMap (\( count, node ) -> node.stats |> List.map (\( stat, level ) -> ( stat, count * level )))
        |> GS.calcStats statsData


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.route of
        Home home ->
            Sub.batch
                [ Window.resizes Resize
                , Draggable.subscriptions DragMsg home.drag
                ]

        _ ->
            Sub.none


dragConfig : Draggable.Config () Msg
dragConfig =
    Draggable.basicConfig (OnDragBy << V2.fromTuple)
