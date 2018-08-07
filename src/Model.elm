module Model
    exposing
    -- types
        ( Msg(..)
        , Model
        , Flags
        , RouteModel(..)
        , HomeModel
        , Error(..)
          -- selectors
        , visibleTooltip
        , nodeSummary
        , statsSummary
        , parseStatsSummary
        , center
        , zoom
        , graphSize
        , nodeIconSize
          -- elm architecture
        , init
        , update
        , subscriptions
        )

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
import Dict.Extra
import Math.Vector2 as V2
import Draggable
import Window
import GameData as G
import GameData.Stats as GS
import Route as Route exposing (Route)
import Model.Dijkstra as Dijkstra
import Model.Graph as Graph
import Ports


type Msg
    = SearchInput String
    | SearchNav (Maybe String) (Maybe String)
    | SearchRegex Ports.SearchRegex
    | NodeMouseDown G.NodeId
    | NodeMouseUp G.NodeId
    | NodeMouseOver G.NodeId
    | NodeMouseOut G.NodeId
    | NodeLongPress G.NodeId
    | NavLocation Navigation.Location
    | Preprocess
    | OnDragBy V2.Vec2
    | DragMsg (Draggable.Msg ())
    | Zoom Float
    | Resize Window.Size
    | ToggleSidebar
    | SaveFileSelected String
    | SaveFileImport Ports.SaveFileData


type alias Model =
    { changelog : String
    , gameData : G.GameData
    , route : RouteModel
    , features : Route.Features
    , windowSize : Window.Size
    }


type RouteModel
    = StatelessRoute Route
    | Home HomeModel
    | HomeError Route.HomeParams


type alias HomeModel =
    -- Data unique to the skill tree page. Lost when leaving the skill tree.
    -- Some of this is redundant with the plain route - for example,
    -- Route.HomeParams.build and HomeModel.selected contain the same information.
    -- This is deliberate - Elm does not have memoization (pure functional!)
    -- so this speeds things up a bit. Be careful when updating.
    { params : Route.HomeParams
    , graph : Graph.GraphModel
    , searchPrev : Maybe String
    , searchString : Maybe String
    , zoom : Float
    , center : V2.Vec2
    , drag : Draggable.State ()
    , tooltip : Maybe ( G.NodeId, TooltipState )
    , sidebarOpen : Bool
    , error : Maybe Error
    }


type Error
    = SearchRegexError String
    | SaveImportError String
    | BuildNodesError String


type TooltipState
    = Hovering
    | Shortpressing
    | Longpressing


type alias Flags =
    { gameData : Decode.Value
    , changelog : String
    , windowSize : Window.Size
    }


init : Flags -> Navigation.Location -> ( Model, Cmd Msg )
init flags loc =
    case Decode.decodeValue G.decoder flags.gameData of
        Ok gameData ->
            let
                route =
                    Route.parse loc
            in
                ( { changelog = flags.changelog
                  , windowSize = flags.windowSize
                  , gameData = gameData
                  , features = Route.parseFeatures loc
                  , route = StatelessRoute Route.NotFound -- placeholder, modified just below
                  }
                    |> \model -> { model | route = route |> routeToModel model }
                , Cmd.batch [ preprocessCmd, Task.perform Resize Window.size, redirectCmd gameData route ]
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
        Route.Home params ->
            case initHome model params of
                Ok m ->
                    Home m

                Err _ ->
                    HomeError params

        _ ->
            StatelessRoute route


invert : comparable -> Set comparable -> Set comparable
invert id set =
    if Set.member id set then
        Set.remove id set
    else
        Set.insert id set


initHome : Model -> Route.HomeParams -> Result String HomeModel
initHome model params =
    let
        create ( graph, partialError ) =
            { params = params
            , graph = graph
            , searchPrev = params.search
            , searchString = params.search
            , zoom =
                clampZoom model.windowSize graph.char.graph <|
                    if graph.selected == Set.empty then
                        1
                    else
                        0
            , center = V2.vec2 0 0
            , drag = Draggable.init
            , tooltip = Nothing
            , sidebarOpen = True
            , error = partialError |> Maybe.map BuildNodesError
            }
    in
        Graph.parse model params |> Result.map create


visibleTooltip : HomeModel -> Maybe G.NodeId
visibleTooltip { tooltip } =
    case tooltip of
        Just ( id, Hovering ) ->
            Just id

        Just ( id, Longpressing ) ->
            Just id

        _ ->
            Nothing


navFromHome : Model -> HomeModel -> Route -> ( RouteModel, Cmd Msg )
navFromHome model old route =
    let
        og =
            old.graph
    in
        case route |> routeToModel model of
            Home new ->
                ( { old
                    | params = new.params
                    , searchString = new.searchString
                    , searchPrev = new.searchPrev
                    , error = Maybe.Extra.or new.error old.error
                    , graph = Graph.updateOnChange new.graph old.graph
                  }
                    |> Home
                , preprocessCmd
                )

            routeModel ->
                ( routeModel, redirectCmd model.gameData route )


updateNode : G.NodeId -> HomeModel -> Model -> ( Model, Cmd Msg )
updateNode id home model =
    let
        selected =
            if Set.member id home.graph.selected then
                -- remove the node, and any disconnected from the start by its removal
                home.graph.selected
                    |> invert id
                    |> Graph.reachableSelectedNodes home.graph.char.graph
            else
                -- add the node and any in between
                Dijkstra.selectPathToNode (Lazy.force home.graph.dijkstra) id
                    |> Set.fromList
                    |> Set.union home.graph.selected

        q =
            home.params

        route =
            Route.Home { q | build = Graph.nodesToBuild home.graph.char.graph selected }
    in
        ( { model | route = Home { home | error = Nothing } }, Navigation.newUrl <| Route.stringify route )


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

                        g =
                            home.graph
                    in
                        -- don't update searchRegex: wait for performance, and for safety.
                        -- https://github.com/erosson/ch2plan/issues/31
                        -- https://github.com/erosson/ch2plan/issues/36
                        -- https://github.com/erosson/ch2plan/issues/44
                        ( { model | route = Home { home | searchPrev = home.searchString, searchString = search } }
                        , Process.sleep (0.3 * Time.second) |> Task.perform (always <| SearchNav home.searchString search)
                        )

                SearchNav from to ->
                    ( model
                    , if home.searchPrev == from then
                        Cmd.batch
                            [ { params | search = to } |> Route.Home |> Route.stringify |> Navigation.modifyUrl
                            , Ports.searchUpdated ()
                            ]
                      else
                        -- they typed something since the delay, do not update the url
                        Cmd.none
                    )

                SearchRegex search ->
                    ( { model
                        | route =
                            Home
                                { home
                                    | graph = Graph.search search home.graph
                                    , error = search.error |> Maybe.map SearchRegexError
                                }
                      }
                    , Cmd.none
                    )

                NodeMouseOver id ->
                    ( { model | route = Home { home | tooltip = Just ( id, Hovering ) } }, Cmd.none )

                NodeMouseOut id ->
                    ( { model | route = Home { home | tooltip = Nothing } }, Cmd.none )

                NodeMouseDown id ->
                    case home.tooltip of
                        Nothing ->
                            -- clicked without hovering - this could be mobile/longpress.
                            -- (could also be a keyboard, but you want to tab through 700 nodes? sorry, not supported)
                            ( { model | route = Home { home | tooltip = Just ( id, Shortpressing ) } }
                            , Process.sleep (0.5 * Time.second) |> Task.perform (always <| NodeLongPress id)
                            )

                        Just ( tid, state ) ->
                            if id /= tid then
                                -- multitouch...? I only support one tooltip at a time
                                ( { model | route = Home { home | tooltip = Just ( id, Shortpressing ) } }
                                , Process.sleep (0.5 * Time.second) |> Task.perform (always <| NodeLongPress id)
                                )
                            else
                                case state of
                                    Hovering ->
                                        -- Mouse-user, clicked while hovering. Select this node, don't wait for mouseout
                                        updateNode id home model

                                    _ ->
                                        -- Multitouch...? Ignore other mousedowns.
                                        ( model, Cmd.none )

                NodeLongPress id ->
                    case home.tooltip of
                        -- waiting for the same longpress that sent this message?
                        Just ( tid, Shortpressing ) ->
                            ( { model | route = Home { home | tooltip = Just ( id, Longpressing ) } }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                NodeMouseUp id ->
                    case home.tooltip of
                        Nothing ->
                            -- no idea how we got here, select the node I guess
                            updateNode id home model

                        Just ( tid, state ) ->
                            if id /= tid then
                                -- no idea how we got here, select the node I guess
                                updateNode id home model
                            else
                                case state of
                                    Hovering ->
                                        -- mouse-user, clicked while hovering. Do nothing, mousedown already selected the node
                                        ( model, Cmd.none )

                                    Shortpressing ->
                                        -- end of a quick tap - select the node and cancel the longpress
                                        updateNode id home { model | route = Home { home | tooltip = Nothing } }

                                    Longpressing ->
                                        -- end of a tooltip longpress - hide the tooltip
                                        ( { model | route = Home { home | tooltip = Nothing } }, Cmd.none )

                Preprocess ->
                    -- calculate dijkstra immediately after the view renders, so we have it ready later, when the user clicks.
                    -- It's not *that* slow - 200ms-ish - but that's slow enough to make a difference.
                    -- This makes things feel much more responsive.
                    --
                    -- Unlike most other things Elm, Lazy is *not* pure-functional. "let _ = ..." normally does nothing,
                    -- but here the side effect is pre-computing dijkstra!
                    let
                        _ =
                            Lazy.force home.graph.dijkstra
                    in
                        ( model, Cmd.none )

                OnDragBy rawDelta ->
                    let
                        delta =
                            rawDelta |> V2.scale (-1 / home.zoom)

                        center =
                            home.center |> V2.add delta |> clampCenter (graphSize model) home
                    in
                        ( { model | route = Home { home | center = center } }, Cmd.none )

                Zoom factor ->
                    let
                        newZoom =
                            home.zoom
                                |> (+) (-factor * 0.01)
                                |> clampZoom (graphSize model) home.graph.char.graph
                    in
                        ( { model | route = Home { home | zoom = newZoom } }, Cmd.none )

                DragMsg dragMsg ->
                    Draggable.update dragConfig dragMsg home
                        |> Tuple.mapFirst (\home2 -> { model | route = Home home2 })

                NavLocation loc ->
                    let
                        ( route, cmd ) =
                            Route.parse loc |> navFromHome model home
                    in
                        ( { model | route = route, features = Route.parseFeatures loc }, cmd )

                Resize windowSize ->
                    ( { model | windowSize = windowSize }, Cmd.none )

                ToggleSidebar ->
                    ( { model | route = Home { home | sidebarOpen = not home.sidebarOpen } }, Cmd.none )

                SaveFileSelected elemId ->
                    ( model, Ports.saveFileSelected elemId )

                SaveFileImport data ->
                    let
                        _ =
                            Debug.log "SaveFileImport" data

                        saveHero =
                            case ( data.error, model.route ) of
                                ( Nothing, Home { params } ) ->
                                    Dict.get params.version model.gameData.byVersion
                                        |> Maybe.withDefault (G.latestVersion model.gameData)
                                        |> (\gvd -> Dict.Extra.find (\k v -> v.name == data.hero) gvd.heroes)

                                _ ->
                                    Nothing

                        saveBuild =
                            String.join "&" data.build

                        q =
                            home.params

                        cmd =
                            case saveHero of
                                Just hero ->
                                    Route.Home { q | hero = Tuple.first hero, build = Just saveBuild }
                                        |> Route.stringify
                                        |> Navigation.newUrl

                                _ ->
                                    Cmd.none
                    in
                        ( { model | route = Home { home | error = data.error |> Maybe.map SaveImportError } }, cmd )

        _ ->
            -- all other routes have no state to preserve or update
            case msg of
                NavLocation loc ->
                    let
                        route =
                            Route.parse loc
                    in
                        ( { model | route = route |> routeToModel model, features = Route.parseFeatures loc }, redirectCmd model.gameData route )

                Resize windowSize ->
                    ( { model | windowSize = windowSize }, Cmd.none )

                _ ->
                    ( model, Cmd.none )


graphSize : { a | features : Route.Features, windowSize : Window.Size } -> Window.Size
graphSize { features, windowSize } =
    if features.fullscreen then
        windowSize
    else
        { width = 1000, height = 1000 }


nodeIconSize =
    50


zoomedGraphSize : HomeModel -> Window.Size -> { width : Float, height : Float }
zoomedGraphSize home window =
    { height = toFloat window.height / home.zoom
    , width = toFloat window.width / home.zoom
    }


clampZoom : Window.Size -> G.Graph -> Float -> Float
clampZoom window graph =
    -- Small windows can zoom out farther, so they can fit the entire graph on screen
    let
        minZoom =
            min
                (toFloat window.width / toFloat (G.graphWidth graph + nodeIconSize * 4))
                (toFloat window.height / toFloat (G.graphHeight graph + nodeIconSize * 4))
                |> min 0.5
    in
        clamp minZoom 3


redirect : G.GameData -> Route -> Maybe Route
redirect gameData route =
    case route of
        Route.Root params ->
            Just <| Route.Home <| Route.delegacy (G.latestVersionId gameData) params

        Route.LegacyHome params ->
            -- legacy urls are assigned a legacy version
            Just <| Route.Home <| Route.delegacy "0.052-beta" params

        _ ->
            Nothing


redirectCmd : G.GameData -> Route -> Cmd Msg
redirectCmd gameData route =
    redirect gameData route
        |> Maybe.Extra.unwrap Cmd.none (Route.stringify >> Navigation.modifyUrl)


zoom : Window.Size -> HomeModel -> Float
zoom window home =
    clampZoom window home.graph.char.graph home.zoom


center : Window.Size -> HomeModel -> V2.Vec2
center window home =
    clampCenter window home home.center


clampCenter : Window.Size -> HomeModel -> V2.Vec2 -> V2.Vec2
clampCenter window0 home =
    let
        ( minXY, maxXY ) =
            centerBounds (window0 |> zoomedGraphSize home) home.graph.char.graph
    in
        -- >> Debug.log "clampCenter"
        v2Clamp minXY maxXY


centerBounds w g =
    -- when panning, for any zoom level, we should stop scrolling around the
    -- edge of the graph, where empty space begins. That means the center is
    -- clamped to a smaller area as zoom gets more distant.
    ( V2.vec2
        ((G.graphMinX g |> toFloat) + w.width / 2 - nodeIconSize |> min 0)
        ((G.graphMinY g |> toFloat) + w.height / 2 - nodeIconSize |> min 0)
    , V2.vec2
        ((G.graphMaxX g |> toFloat) - w.width / 2 + nodeIconSize |> max 0)
        ((G.graphMaxY g |> toFloat) - w.height / 2 + nodeIconSize |> max 0)
    )


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


nodeSummary : { a | selected : Set G.NodeId, char : G.Character } -> List ( Int, G.NodeType )
nodeSummary { selected, char } =
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


statsSummary : { a | selected : Set G.NodeId, char : G.Character, game : G.GameVersionData } -> List GS.StatTotal
statsSummary g =
    nodeSummary g
        |> List.concatMap (\( count, node ) -> node.stats |> List.map (\( stat, level ) -> ( stat, count * level )))
        |> GS.calcStats g.game.stats


parseStatsSummary :
    Model
    -> Route.HomeParams
    ->
        Result String
            { selected : Set G.NodeId
            , char : G.Character
            , game : G.GameVersionData
            , nodes : List ( Int, G.NodeType )
            , stats : List GS.StatTotal
            }
parseStatsSummary model params =
    Graph.parse model params
        |> Result.map
            (Tuple.first
                >> \m ->
                    { selected = m.selected
                    , char = m.char
                    , game = m.game
                    , nodes = nodeSummary m
                    , stats = statsSummary m
                    }
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.route of
        Home home ->
            Sub.batch
                [ Window.resizes Resize
                , Draggable.subscriptions DragMsg home.drag
                , Ports.saveFileContentRead SaveFileImport
                , Ports.searchRegex SearchRegex
                ]

        _ ->
            Sub.none


dragConfig : Draggable.Config () Msg
dragConfig =
    Draggable.basicConfig (OnDragBy << V2.fromTuple)
