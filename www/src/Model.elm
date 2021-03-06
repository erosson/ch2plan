module Model exposing
    ( Error(..)
    , Flags
    , Model
    , Msg(..)
    , NodeTypeSummary
    , StatsSummary
    , TooltipState(..)
    , center
    , init
    , nodeIconSize
    , nodeSummary
    , parseStatsSummary
    , statsSummary
    , subscriptions
    , update
    , visibleTooltip
    , zoom
    )

import Browser
import Browser.Events
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Dict.Extra
import Draggable
import GameData exposing (GameData, Graph, NodeId, NodeType)
import GameData.Stats as Stats exposing (Stat, StatTotal)
import Json.Decode as D
import Lazy exposing (Lazy)
import List.Extra
import Math.Vector2 as V2
import Maybe.Extra
import Model.Dijkstra as Dijkstra
import Model.Graph as Graph exposing (GraphModel)
import Model.Runecorder as Runecorder
import Ports
import Process
import Regex exposing (Regex)
import Route exposing (Features, Route)
import SaveFile exposing (SaveFile)
import Set exposing (Set)
import Task
import Time
import Url exposing (Url)


type Msg
    = SearchInput String
    | SearchNav (Maybe String) (Maybe String)
    | SearchHelp Bool
    | NodeMouseDown NodeId Bool
    | NodeMouseUp NodeId
    | NodeMouseOver NodeId
    | NodeMouseOut NodeId
    | NodeLongPress NodeId
    | NavRequest Browser.UrlRequest
    | NavLocation Url
    | Preprocess
    | OnDragBy V2.Vec2
    | DragMsg (Draggable.Msg ())
    | Zoom Float
    | Resize WindowSize
    | ToggleSidebar
    | SaveFileSelected String
    | SaveFileImport D.Value
    | TextImport String
    | RunecorderAppend String
    | RunecorderInput String
    | RunecorderSelect (Maybe Int)
    | RunecorderRun
    | TranscendNodeUpgrade NodeId
    | TranscendNodeDowngrade NodeId
    | TranscendPerkInput Int String


type alias Model =
    { urlKey : Nav.Key
    , changelog : String
    , gameData : Result D.Error GameData
    , route : Maybe Route
    , graph : Maybe GraphModel
    , transcendNodes : Dict NodeId Int
    , transcendPerks : Dict Int Int
    , features : Features
    , windowSize : WindowSize
    , tooltip : Maybe ( NodeId, TooltipState )
    , sidebarOpen : Bool
    , searchString : Maybe String
    , searchPrev : Maybe String
    , searchRegex : Maybe Regex
    , searchHelp : Bool
    , zoom : Float
    , center : V2.Vec2
    , drag : Draggable.State ()
    , etherealItemInventory : Maybe SaveFile.EtherealItemInventory
    , runecorderSource : String
    , runecorderSim : ( String, Result (List Runecorder.DeadEnd) Runecorder.SimTimeline )
    , runecorderSelection : Maybe Int
    , error : Maybe Error
    }


type alias WindowSize =
    { width : Int, height : Int }


type Error
    = SearchRegexError
    | SaveImportError String
    | BuildNodesError String
    | GraphError String


type TooltipState
    = Hovering
    | Shortpressing
    | Longpressing
    | CtrlClicking


type alias Flags =
    { gameData : D.Value
    , changelog : String
    , windowSize : WindowSize
    }


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags loc urlKey =
    let
        gameData =
            D.decodeValue GameData.decoder flags.gameData

        route =
            Route.parse loc

        search =
            route |> Maybe.andThen Route.params |> Maybe.andThen .search

        ( graph, error ) =
            case gameData of
                Err err ->
                    ( Nothing, Just <| GraphError "no graph without gamedata" )

                Ok gd ->
                    parseGraph gd route

        src =
            case route of
                Just (Route.Runecorder (Just source)) ->
                    source

                _ ->
                    Runecorder.example1
    in
    ( { urlKey = urlKey
      , changelog = flags.changelog
      , windowSize = flags.windowSize
      , gameData = gameData
      , features = Route.parseFeatures loc
      , route = route
      , graph = graph
      , transcendNodes = Dict.empty
      , transcendPerks = Dict.empty
      , sidebarOpen = True
      , tooltip = Nothing
      , searchString = search
      , searchPrev = search
      , searchRegex = Just Regex.never
      , searchHelp = False
      , zoom =
            graph
                |> Maybe.Extra.unwrap 1
                    (\{ char, selected } ->
                        clampZoom flags.windowSize char.graph <|
                            if Set.isEmpty selected.set then
                                1

                            else
                                0
                    )
      , center = V2.vec2 0 0
      , drag = Draggable.init
      , etherealItemInventory = Nothing
      , runecorderSource = src
      , runecorderSim = ( src, Err [] )
      , runecorderSelection = Nothing
      , error = error
      }
        |> (case gameData of
                Ok gd ->
                    runecorderRun gd

                _ ->
                    identity
           )
    , Cmd.batch
        [ preprocessCmd
        , redirectCmd urlKey route
        ]
    )


parseGraph : GameData -> Maybe Route -> ( Maybe GraphModel, Maybe Error )
parseGraph gameData route =
    let
        graphResult =
            route
                |> Maybe.andThen Route.params
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


visibleTooltip : Model -> Maybe NodeId
visibleTooltip { tooltip } =
    case tooltip of
        Just ( id, Hovering ) ->
            Just id

        Just ( id, Longpressing ) ->
            Just id

        Just ( id, CtrlClicking ) ->
            Just id

        _ ->
            Nothing


{-| Toggle a clicked node-id
-}
updateNode : NodeId -> Model -> ( Model, Cmd Msg )
updateNode id model =
    Maybe.map2
        (\graph params ->
            let
                selected =
                    if Set.member id graph.selected.set then
                        -- deselect a node: remove it, and any disconnected from the start by its removal
                        graph.selected
                            |> Graph.removeSelected id
                            |> Graph.reachableSelectedNodes graph.char.graph

                    else
                        -- select a node: add it, and any in between
                        graph.selected.list
                            ++ (id
                                    |> Dijkstra.selectPathToNode (Lazy.force graph.dijkstra)
                                    |> List.filter (\n -> Set.member n graph.selected.set |> not)
                               )
                            |> Graph.createSelected

                route =
                    Route.Home
                        { params | build = Graph.nodesToBuild graph.char.graph selected }
            in
            ( { model | error = Nothing }, Nav.pushUrl model.urlKey <| Route.stringify route )
        )
        model.graph
        (model.route |> Maybe.andThen Route.params)
        -- if we don't have a graph or a graph-url, how did the user even click?
        |> Maybe.withDefault ( model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model.gameData of
        Err err ->
            ( model, Cmd.none )

        Ok gameData ->
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
                    -- don't update searchRegex: wait, for performance.
                    -- (Safety's not an issue anymore; Elm 0.19 fixed #44's crashes)
                    -- https://github.com/erosson/ch2plan/issues/31
                    -- https://github.com/erosson/ch2plan/issues/36
                    -- https://github.com/erosson/ch2plan/issues/44
                    ( { model | searchPrev = model.searchString, searchString = search }
                    , Process.sleep 300 |> Task.perform (always <| SearchNav model.searchString search)
                    )

                SearchNav from to ->
                    if model.searchPrev == from then
                        case model.route of
                            Just (Route.Home params) ->
                                let
                                    searchRegex =
                                        to
                                            |> Maybe.andThen
                                                (Regex.fromStringWith { caseInsensitive = True, multiline = True })

                                    error =
                                        case ( to, searchRegex ) of
                                            ( Nothing, _ ) ->
                                                Nothing

                                            ( Just _, Just _ ) ->
                                                Nothing

                                            ( Just _, Nothing ) ->
                                                Just SearchRegexError
                                in
                                ( { model | graph = model.graph |> Maybe.map (\g -> { g | search = searchRegex }), error = error }
                                , { params | search = to } |> Route.Home |> Route.stringify |> Nav.replaceUrl model.urlKey
                                )

                            _ ->
                                -- can't search from pages without a searchbox
                                ( model, Cmd.none )

                    else
                        -- they typed something since the delay, do not update the url
                        ( model, Cmd.none )

                NodeMouseOver id ->
                    if model.tooltip == Just ( id, CtrlClicking ) then
                        ( model, Cmd.none )

                    else
                        ( { model | tooltip = Just ( id, Hovering ) }, Cmd.none )

                NodeMouseOut id ->
                    if model.tooltip == Just ( id, CtrlClicking ) then
                        ( model, Cmd.none )

                    else
                        ( { model | tooltip = Nothing }, Cmd.none )

                NodeMouseDown id ctrlKey ->
                    case model.tooltip of
                        Nothing ->
                            -- clicked without hovering - this could be mobile/longpress.
                            -- (could also be a keyboard, but you want to tab through 700 nodes? sorry, not supported)
                            ( { model | tooltip = Just ( id, Shortpressing ) }
                            , Process.sleep 500 |> Task.perform (always <| NodeLongPress id)
                            )

                        Just ( tid, state ) ->
                            if id /= tid then
                                -- multitouch...? I only support one tooltip at a time
                                ( { model | tooltip = Just ( id, Shortpressing ) }
                                , Process.sleep 500 |> Task.perform (always <| NodeLongPress id)
                                )

                            else
                                case state of
                                    Hovering ->
                                        if model.features.transcendNodes && ctrlKey then
                                            -- Ctrl-click displays a persistent tooltip
                                            ( { model | tooltip = Just ( id, CtrlClicking ) }, Cmd.none )

                                        else
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

                                    CtrlClicking ->
                                        -- mouse-user, end of a ctrl-click
                                        ( model, Cmd.none )

                Preprocess ->
                    -- calculate dijkstra immediately after the view renders, so we have it ready later, when the user clicks.
                    -- It's not *that* slow - 200ms-ish - but that's slow enough to make a difference.
                    -- This makes things feel much more responsive.
                    ( { model | graph = model.graph |> Maybe.map (\g -> { g | dijkstra = Lazy.evaluate g.dijkstra }) }, Cmd.none )

                OnDragBy rawDelta ->
                    let
                        delta =
                            rawDelta |> V2.scale (-1 / model.zoom)
                    in
                    ( { model | center = model.center |> V2.add delta }, Cmd.none )

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

                TextImport str ->
                    let
                        cmd : Cmd Msg
                        cmd =
                            case model.route of
                                Just (Route.Home params) ->
                                    Route.Home { params | build = Just str }
                                        |> Route.stringify
                                        |> Nav.pushUrl model.urlKey

                                _ ->
                                    Cmd.none
                    in
                    ( model, cmd )

                SaveFileSelected elemId ->
                    ( model, Ports.saveFileSelected elemId )

                SaveFileImport json ->
                    case D.decodeValue SaveFile.decoder json of
                        Err err ->
                            ( { model
                                | etherealItemInventory = Nothing
                                , error = err |> D.errorToString |> SaveImportError |> Just
                              }
                            , Cmd.none
                            )

                        Ok data ->
                            case model.graph |> Maybe.map .game |> Maybe.Extra.orElse (GameData.latestVersion gameData) of
                                Nothing ->
                                    ( { model
                                        | etherealItemInventory = Nothing
                                        , error = "unknown saved game version" |> SaveImportError |> Just
                                      }
                                    , Cmd.none
                                    )

                                Just game ->
                                    let
                                        saveHero =
                                            Dict.Extra.find (\k v -> v.name == data.hero) game.heroes

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
                                                        |> Nav.pushUrl model.urlKey

                                                _ ->
                                                    Cmd.none
                                    in
                                    ( { model
                                        | etherealItemInventory = Just data.etherealItemInventory
                                        , error = Nothing
                                      }
                                    , cmd
                                    )

                RunecorderAppend line ->
                    ( { model
                        | runecorderSource =
                            if model.runecorderSource == "" then
                                line

                            else
                                model.runecorderSource ++ "\n" ++ line
                      }
                        |> runecorderRun gameData
                    , Cmd.none
                    )

                RunecorderInput input ->
                    ( { model | runecorderSource = input }, Cmd.none )

                RunecorderSelect val ->
                    ( { model | runecorderSelection = val }, Cmd.none )

                RunecorderRun ->
                    -- ( runecorderRun gameData model, Cmd.none )
                    ( model, Nav.pushUrl model.urlKey <| Route.stringify <| Route.Runecorder <| Just model.runecorderSource )

                NavRequest req ->
                    -- https://package.elm-lang.org/packages/elm/browser/latest/Browser#UrlRequest
                    case req of
                        Browser.Internal url ->
                            ( model, Nav.pushUrl model.urlKey (Url.toString url) )

                        Browser.External url ->
                            ( model, Nav.load url )

                NavLocation loc ->
                    let
                        route : Maybe Route
                        route =
                            Route.parse loc

                        ( graph, error ) =
                            parseGraph gameData route

                        src =
                            case route of
                                Just (Route.Runecorder (Just source)) ->
                                    source

                                _ ->
                                    ""
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
                        , runecorderSource = src
                      }
                        |> runecorderRun gameData
                    , Cmd.batch [ preprocessCmd, redirectCmd model.urlKey route ]
                    )

                Resize windowSize ->
                    ( { model | windowSize = windowSize }, Cmd.none )

                TranscendNodeUpgrade id ->
                    ( { model | transcendNodes = model.transcendNodes |> transcendNodeIncr id 1 }, Cmd.none )

                TranscendNodeDowngrade id ->
                    ( { model | transcendNodes = model.transcendNodes |> transcendNodeIncr id -1 }, Cmd.none )

                TranscendPerkInput id str ->
                    ( { model | transcendPerks = model.transcendPerks |> transcendPerkInput id str }, Cmd.none )


transcendPerkInput : Int -> String -> Dict Int Int -> Dict Int Int
transcendPerkInput id input =
    if input == "" then
        Dict.remove id

    else
        case String.toInt input of
            Nothing ->
                identity

            Just val ->
                val |> max 0 |> Dict.insert id


transcendNodeIncr : NodeId -> Int -> Dict NodeId Int -> Dict NodeId Int
transcendNodeIncr nodeId val =
    Dict.update nodeId
        (Maybe.withDefault 1
            >> (+) val
            >> (\v ->
                    if v <= 1 then
                        Nothing

                    else
                        Just v
               )
        )


runecorderRun : GameData -> Model -> Model
runecorderRun gameData model =
    { model
        | runecorderSim =
            ( model.runecorderSource
            , case GameData.wizardSpells gameData of
                Nothing ->
                    Err []

                Just ( char, spells ) ->
                    Runecorder.parseAndRun spells model.runecorderSource
            )
    }


nodeIconSize =
    50


zoomedGraphSize : Model -> WindowSize -> { width : Float, height : Float }
zoomedGraphSize model window =
    { height = toFloat window.height / model.zoom
    , width = toFloat window.width / model.zoom
    }


clampZoom : WindowSize -> Graph -> Float -> Float
clampZoom window graph =
    -- Small windows can zoom out farther, so they can fit the entire graph on screen
    let
        minZoom =
            min
                (toFloat window.width / toFloat (GameData.graphWidth graph + nodeIconSize * 4))
                (toFloat window.height / toFloat (GameData.graphHeight graph + nodeIconSize * 4))
                |> min 0.5
    in
    clamp minZoom 3


redirectRoute : Route -> Maybe Route
redirectRoute route =
    case route of
        Route.Redirect r ->
            redirectRoute r |> Maybe.withDefault r |> Just

        _ ->
            Nothing


redirectCmd : Nav.Key -> Maybe Route -> Cmd Msg
redirectCmd urlKey route =
    case route |> Maybe.andThen redirectRoute of
        Nothing ->
            Cmd.none

        Just r ->
            r |> Route.stringify |> Nav.replaceUrl urlKey


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
    v2Clamp minXY maxXY


centerBounds w g =
    -- when panning, for any zoom level, we should stop scrolling around the
    -- edge of the graph, where empty space begins. That means the center is
    -- clamped to a smaller area as zoom gets more distant.
    ( V2.vec2
        ((GameData.graphMinX g |> toFloat) + w.width / 2 - nodeIconSize |> min 0)
        ((GameData.graphMinY g |> toFloat) + w.height / 2 - nodeIconSize |> min 0)
    , V2.vec2
        ((GameData.graphMaxX g |> toFloat) - w.width / 2 + nodeIconSize |> max 0)
        ((GameData.graphMaxY g |> toFloat) - w.height / 2 + nodeIconSize |> max 0)
    )


v2Clamp : V2.Vec2 -> V2.Vec2 -> V2.Vec2 -> V2.Vec2
v2Clamp minV maxV v =
    V2.vec2
        (clamp (V2.getX minV) (V2.getX maxV) (V2.getX v))
        (clamp (V2.getY minV) (V2.getY maxV) (V2.getY v))


type alias NodeTypeSummary =
    { nodeType : NodeType
    , transcendLevel : Int
    , count : Int
    }


nodeSummary : { m | transcendNodes : Dict NodeId Int } -> { a | selected : Graph.Selected, char : GameData.Character } -> List NodeTypeSummary
nodeSummary m { selected, char } =
    let
        selectedNodes : Dict NodeId ( NodeType, Int )
        selectedNodes =
            char.graph.nodes
                |> Dict.filter (\id nodeType -> Set.member id selected.set)
                |> Dict.map (\id n -> ( n.val, m.transcendNodes |> Dict.get id |> Maybe.withDefault 1 ))
    in
    selectedNodes
        |> Dict.values
        |> List.sortBy (\( n, tlvl ) -> ( n.name, tlvl ))
        |> List.Extra.group
        |> List.map (\( ( nodeType, tlvl ), tail ) -> { nodeType = nodeType, count = List.length tail + 1, transcendLevel = tlvl })
        |> List.sortBy
            (\{ count, nodeType } ->
                -1
                    * (count
                        -- I really can't sort on a tuple, Elm? Sigh.
                        + (case nodeType.quality of
                            GameData.Keystone ->
                                1000000

                            GameData.Notable ->
                                1000

                            GameData.Plain ->
                                0
                          )
                      )
            )


statsSummary : { m | transcendNodes : Dict NodeId Int } -> { a | selected : Graph.Selected, char : GameData.Character, game : GameData.GameVersionData } -> List StatTotal
statsSummary m g =
    nodeSummary m g
        |> List.concatMap (\s -> s.nodeType.stats |> List.map (\( stat, level ) -> ( stat, s.transcendLevel * s.count * level )))
        |> Stats.calcAllStats g.game.stats


type alias StatsSummary =
    { selected : Graph.Selected
    , char : GameData.Character
    , game : GameData.GameVersionData
    , nodes : List NodeTypeSummary
    , stats : List StatTotal
    , params : Route.HomeParams
    }


parseStatsSummary : Model -> GameData -> Route.HomeParams -> Result String StatsSummary
parseStatsSummary model gd params =
    Graph.parse gd params
        |> Result.map
            (Tuple.first
                >> (\m ->
                        { selected = m.selected
                        , char = m.char
                        , game = m.game
                        , nodes = nodeSummary model m
                        , stats = statsSummary model m
                        , params = params
                        }
                   )
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Browser.Events.onResize (\w h -> WindowSize w h |> Resize)
        , Draggable.subscriptions DragMsg model.drag
        , Ports.saveFileContentRead SaveFileImport
        ]


dragConfig : Draggable.Config () Msg
dragConfig =
    Draggable.basicConfig (\( x, y ) -> V2.vec2 x y |> OnDragBy)
