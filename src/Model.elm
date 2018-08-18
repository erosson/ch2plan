module Model
    exposing
    -- types
        ( Msg(..)
        , Model
        , Flags
        , Error(..)
        , StatsSummary
          -- selectors
        , visibleTooltip
        , nodeSummary
        , statsSummary
        , parseStatsSummary
        , center
        , zoom
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
import Route as Route exposing (Route, Features)
import Model.Dijkstra as Dijkstra
import Model.Graph as Graph exposing (GraphModel)
import Ports


type Msg
    = SearchInput String
    | SearchNav (Maybe String) (Maybe String)
    | SearchRegex Ports.SearchRegex
    | SearchHelp Bool
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
    , route : Route
    , graph : Maybe Graph.GraphModel
    , features : Features
    , windowSize : Window.Size
    , tooltip : Maybe ( G.NodeId, TooltipState )
    , sidebarOpen : Bool
    , searchString : Maybe String
    , searchPrev : Maybe String
    , searchRegex : Maybe Regex
    , searchHelp : Bool
    , zoom : Float
    , center : V2.Vec2
    , drag : Draggable.State ()
    , error : Maybe Error
    }


type Error
    = SearchRegexError String
    | SaveImportError String
    | BuildNodesError String
    | GraphError String


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

                search =
                    Route.params route |> Maybe.Extra.unwrap Nothing .search

                ( graph, error ) =
                    parseGraph gameData route
            in
                ( { changelog = flags.changelog
                  , windowSize = flags.windowSize
                  , gameData = gameData
                  , features = Route.parseFeatures loc
                  , route = route
                  , graph = graph
                  , sidebarOpen = True
                  , tooltip = Nothing
                  , searchString = search
                  , searchPrev = search
                  , searchRegex = Nothing -- this is populated later, from ports/SearchRegex message
                  , searchHelp = False
                  , zoom =
                        graph
                            |> Maybe.Extra.unwrap 1
                                (\{ char, selected } ->
                                    clampZoom flags.windowSize char.graph <|
                                        if selected == Set.empty then
                                            1
                                        else
                                            0
                                )
                  , center = V2.vec2 0 0
                  , drag = Draggable.init
                  , error = error
                  }
                , Cmd.batch [ preprocessCmd, Task.perform Resize Window.size, redirectCmd gameData route ]
                )

        Err err ->
            Debug.crash err


parseGraph : G.GameData -> Route -> ( Maybe GraphModel, Maybe Error )
parseGraph gameData route =
    let
        graphResult =
            Route.params route
                |> Result.fromMaybe "cannot graph this url"
                |> Result.andThen (Graph.parse gameData)
    in
        case graphResult of
            Err err ->
                ( Nothing, Just <| GraphError err )

            Ok ( g, Just err ) ->
                ( Just g, Just <| BuildNodesError err )

            Ok ( g, Nothing ) ->
                ( Just g, Nothing )


preprocessCmd : Cmd Msg
preprocessCmd =
    -- setTimeout to let the UI render, then run delayed calculations
    Process.sleep 1
        |> Task.andThen (always <| Task.succeed Preprocess)
        |> Task.perform identity


invert : comparable -> Set comparable -> Set comparable
invert id set =
    if Set.member id set then
        Set.remove id set
    else
        Set.insert id set


visibleTooltip : Model -> Maybe G.NodeId
visibleTooltip { tooltip } =
    case tooltip of
        Just ( id, Hovering ) ->
            Just id

        Just ( id, Longpressing ) ->
            Just id

        _ ->
            Nothing


updateNode : G.NodeId -> Model -> ( Model, Cmd Msg )
updateNode id model =
    let
        graph =
            case model.graph of
                Nothing ->
                    Debug.crash "can't updateNode without model.graph"

                Just graph ->
                    graph

        params =
            case Route.params model.route of
                Nothing ->
                    Debug.crash "can't updateNode without route params"

                Just params ->
                    params

        selected =
            if Set.member id graph.selected then
                -- remove the node, and any disconnected from the start by its removal
                graph.selected
                    |> invert id
                    |> Graph.reachableSelectedNodes graph.char.graph
            else
                -- add the node and any in between
                Dijkstra.selectPathToNode (Lazy.force graph.dijkstra) id
                    |> Set.fromList
                    |> Set.union graph.selected

        route =
            Route.Home
                { params | build = Graph.nodesToBuild graph.char.graph selected }
    in
        ( { model | error = Nothing }, Navigation.newUrl <| Route.stringify route )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SearchHelp open ->
            ( { model | searchHelp = open }, Cmd.none )

        SearchInput search0 ->
            -- Typing out a search in the search box. Do nothing while
            -- they type; when they stop typing, perform the search.
            let
                search =
                    if search0 == "" then
                        Nothing
                    else
                        Just search0
            in
                -- don't update searchRegex: wait for performance, and for safety.
                -- https://github.com/erosson/ch2plan/issues/31
                -- https://github.com/erosson/ch2plan/issues/36
                -- https://github.com/erosson/ch2plan/issues/44
                ( { model | searchPrev = model.searchString, searchString = search }
                , Process.sleep (0.3 * Time.second) |> Task.perform (always <| SearchNav model.searchString search)
                )

        SearchNav from to ->
            ( model
            , if model.searchPrev == from then
                case model.route of
                    Route.Home params ->
                        Cmd.batch
                            [ { params | search = to } |> Route.Home |> Route.stringify |> Navigation.modifyUrl
                            , Ports.searchUpdated ()
                            ]

                    _ ->
                        -- can't search from pages without a searchbox
                        Cmd.none
              else
                -- they typed something since the delay, do not update the url
                Cmd.none
            )

        SearchRegex search ->
            ( { model
                | graph = model.graph |> Maybe.map (Graph.search search)
                , error = search.error |> Maybe.map SearchRegexError
              }
            , Cmd.none
            )

        NodeMouseOver id ->
            ( { model | tooltip = Just ( id, Hovering ) }, Cmd.none )

        NodeMouseOut id ->
            ( { model | tooltip = Nothing }, Cmd.none )

        NodeMouseDown id ->
            case model.tooltip of
                Nothing ->
                    -- clicked without hovering - this could be mobile/longpress.
                    -- (could also be a keyboard, but you want to tab through 700 nodes? sorry, not supported)
                    ( { model | tooltip = Just ( id, Shortpressing ) }
                    , Process.sleep (0.5 * Time.second) |> Task.perform (always <| NodeLongPress id)
                    )

                Just ( tid, state ) ->
                    if id /= tid then
                        -- multitouch...? I only support one tooltip at a time
                        ( { model | tooltip = Just ( id, Shortpressing ) }
                        , Process.sleep (0.5 * Time.second) |> Task.perform (always <| NodeLongPress id)
                        )
                    else
                        case state of
                            Hovering ->
                                -- Mouse-user, clicked while hovering. Select this node, don't wait for mouseout
                                updateNode id model

                            _ ->
                                -- Multitouch...? Ignore other mousedowns.
                                ( model, Cmd.none )

        NodeLongPress id ->
            case model.tooltip of
                -- waiting for the same longpress that sent this message?
                Just ( tid, Shortpressing ) ->
                    ( { model | tooltip = Just ( id, Longpressing ) }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        NodeMouseUp id ->
            case model.tooltip of
                Nothing ->
                    -- no idea how we got here, select the node I guess
                    updateNode id model

                Just ( tid, state ) ->
                    if id /= tid then
                        -- no idea how we got here, select the node I guess
                        updateNode id model
                    else
                        case state of
                            Hovering ->
                                -- mouse-user, clicked while hovering. Do nothing, mousedown already selected the node
                                ( model, Cmd.none )

                            Shortpressing ->
                                -- end of a quick tap - select the node and cancel the longpress
                                updateNode id { model | tooltip = Nothing }

                            Longpressing ->
                                -- end of a tooltip longpress - hide the tooltip
                                ( { model | tooltip = Nothing }, Cmd.none )

        Preprocess ->
            -- calculate dijkstra immediately after the view renders, so we have it ready later, when the user clicks.
            -- It's not *that* slow - 200ms-ish - but that's slow enough to make a difference.
            -- This makes things feel much more responsive.
            --
            -- Unlike most other things Elm, Lazy is *not* pure-functional. "let _ = ..." normally does nothing,
            -- but here the side effect is pre-computing dijkstra!
            let
                _ =
                    model.graph |> Maybe.map (\g -> Lazy.force g.dijkstra)
            in
                ( model, Cmd.none )

        OnDragBy rawDelta ->
            let
                delta =
                    rawDelta |> V2.scale (-1 / model.zoom)

                center =
                    model.center
                        |> V2.add delta

                --|> clampCenter model
            in
                ( { model | center = center }, Cmd.none )

        Zoom factor ->
            let
                newZoom =
                    model.graph
                        |> Maybe.map
                            (\{ char } ->
                                model.zoom
                                    |> (+) (-factor * 0.01)
                                    |> clampZoom model.windowSize char.graph
                            )
                        |> Maybe.withDefault model.zoom
            in
                ( { model | zoom = newZoom }, Cmd.none )

        DragMsg dragMsg ->
            Draggable.update dragConfig dragMsg model

        ToggleSidebar ->
            ( { model | sidebarOpen = not model.sidebarOpen }, Cmd.none )

        SaveFileSelected elemId ->
            ( model, Ports.saveFileSelected elemId )

        SaveFileImport data ->
            let
                _ =
                    Debug.log "SaveFileImport" data

                game =
                    model.graph |> Maybe.map .game |> Maybe.withDefault (G.latestVersion model.gameData)

                saveHero =
                    case data.error of
                        Nothing ->
                            Dict.Extra.find (\k v -> v.name == data.hero) game.heroes

                        _ ->
                            Nothing

                saveBuild =
                    String.join "&" data.build

                cmd =
                    case saveHero of
                        Just hero ->
                            Route.Home
                                { version = game.versionSlug
                                , search = model.searchString
                                , hero = Tuple.first hero
                                , build = Just saveBuild
                                }
                                |> Route.stringify
                                |> Navigation.newUrl

                        _ ->
                            Cmd.none
            in
                -- show errors, and/or redirect to the imported build
                ( { model | error = data.error |> Maybe.map SaveImportError }, cmd )

        NavLocation loc ->
            let
                route =
                    Route.parse loc

                ( graph, error ) =
                    parseGraph model.gameData route
            in
                ( { model
                    | route = route
                    , features = Route.parseFeatures loc
                    , error = error
                    , graph =
                        case ( graph, model.graph ) of
                            ( Just new, Just old ) ->
                                Just <| Graph.updateOnChange new old

                            ( Just new, Nothing ) ->
                                Just new

                            _ ->
                                Nothing
                  }
                , Cmd.batch [ preprocessCmd, redirectCmd model.gameData route ]
                )

        Resize windowSize ->
            ( { model | windowSize = windowSize }, Cmd.none )


nodeIconSize =
    50


zoomedGraphSize : Model -> Window.Size -> { width : Float, height : Float }
zoomedGraphSize model window =
    { height = toFloat window.height / model.zoom
    , width = toFloat window.width / model.zoom
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
            Just <| Route.Home <| Route.fromLegacyParams (G.latestVersionId gameData) params

        Route.LegacyHome params ->
            -- legacy urls are assigned a legacy version
            Just <| Route.Home <| Route.fromLegacyParams "0.052-beta" params

        _ ->
            Nothing


redirectCmd : G.GameData -> Route -> Cmd Msg
redirectCmd gameData route =
    redirect gameData route
        |> Maybe.Extra.unwrap Cmd.none (Route.stringify >> Navigation.modifyUrl)


zoom : Model -> GraphModel -> Float
zoom model { char } =
    clampZoom model.windowSize char.graph model.zoom


center : Model -> GraphModel -> V2.Vec2
center model home =
    clampCenter model home model.center


clampCenter : Model -> GraphModel -> V2.Vec2 -> V2.Vec2
clampCenter model { char } =
    let
        ( minXY, maxXY ) =
            centerBounds (model.windowSize |> zoomedGraphSize model) char.graph
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


type alias StatsSummary =
    { selected : Set G.NodeId
    , char : G.Character
    , game : G.GameVersionData
    , nodes : List ( Int, G.NodeType )
    , stats : List GS.StatTotal
    , params : Route.HomeParams
    }


parseStatsSummary : Model -> Route.HomeParams -> Result String StatsSummary
parseStatsSummary model params =
    Graph.parse model.gameData params
        |> Result.map
            (Tuple.first
                >> \m ->
                    { selected = m.selected
                    , char = m.char
                    , game = m.game
                    , nodes = nodeSummary m
                    , stats = statsSummary m
                    , params = params
                    }
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Window.resizes Resize
        , Draggable.subscriptions DragMsg model.drag
        , Ports.saveFileContentRead SaveFileImport
        , Ports.searchRegex SearchRegex
        ]


dragConfig : Draggable.Config () Msg
dragConfig =
    Draggable.basicConfig (OnDragBy << V2.fromTuple)
