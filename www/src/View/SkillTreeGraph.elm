module View.SkillTreeGraph exposing (panOffsets, sidebarWidth, view)

{-| Svg parts of the SkillTree page

Don't import Html!

also don't `import svg exposing (..)` the way we would with html: svg is much less familiar

-}

import Dict exposing (Dict)
import Draggable
import GameData exposing (GameData)
import Json.Decode as Decode
import List.Extra
import Math.Vector2 as V2
import Maybe.Extra
import Model exposing (Model, Msg)
import Model.Graph as Graph exposing (GraphModel)
import Regex exposing (Regex)
import Route exposing (Route)
import Set exposing (Set)
import Svg as S exposing (Svg)
import Svg.Attributes as A
import Svg.Events as E
import Svg.Lazy as L
import View.Util
import VirtualDom


view : Model -> GraphModel -> Svg Msg
view model graph =
    S.svg
        inputZoomAndPan
        [ S.defs []
            [ S.filter [ A.id "edge" ] [ S.feGaussianBlur [ A.in_ "SourceGraphic", A.stdDeviation "2" ] [] ]
            , S.filter [ A.id "edgeSelected" ] [ S.feGaussianBlur [ A.in_ "SourceGraphic", A.stdDeviation "4" ] [] ]
            , S.filter [ A.id "highlight0" ] [ S.feColorMatrix [ A.type_ "hueRotate", A.values "0" ] [] ]
            , S.filter [ A.id "highlight1" ] [ S.feColorMatrix [ A.type_ "hueRotate", A.values "180" ] [] ]

            -- , S.filter [ A.id "highlight2" ] [ S.feColorMatrix [ A.type_ "hueRotate", A.values "90" ] [] ] -- selected-green
            , S.filter [ A.id "highlight2" ] [ S.feColorMatrix [ A.type_ "hueRotate", A.values "270" ] [] ]
            , S.filter [ A.id "highlight3" ] [ S.feColorMatrix [ A.type_ "hueRotate", A.values "45" ] [] ]

            -- , S.filter [ A.id "highlight4" ] [ S.feColorMatrix [ A.type_ "hueRotate", A.values "135" ] [] ] -- selected-green again
            , S.filter [ A.id "highlight4" ] [ S.feColorMatrix [ A.type_ "hueRotate", A.values "225" ] [] ]
            , S.filter [ A.id "highlight5" ] [ S.feColorMatrix [ A.type_ "hueRotate", A.values "315" ] [] ]
            ]
        , S.g [ zoomAndPan model graph ]
            [ graph |> L.lazy2 viewEdges False
            , graph |> L.lazy2 viewEdges True
            , graph |> L.lazy viewNodeBackgrounds
            , graph |> L.lazy2 viewNodes model.features
            ]
        , viewZoomButtons model.windowSize
        ]


debug : String -> ()
debug s =
    -- Uncomment this to diagnose redraw/lag problems
    -- Debug.log s ()
    ()


viewNodeBackgrounds : GraphModel -> Svg msg
viewNodeBackgrounds home =
    let
        _ =
            debug "redraw backgrounds"
    in
    home.char.graph.nodes |> Dict.toList |> List.map (viewNodeBackground home << Tuple.second) |> S.g []


viewNodes : Route.Features -> GraphModel -> Svg Msg
viewNodes features home =
    let
        _ =
            debug "redraw nodes"
    in
    home.char.graph.nodes |> Dict.toList |> List.map (viewNode features home << Tuple.second) |> S.g []


viewEdges : Bool -> GraphModel -> Svg msg
viewEdges selected home =
    let
        _ =
            debug "redraw edges"

        ( edges, classes ) =
            if selected then
                ( List.filter (\e -> isEdgeSelected home e) <| Dict.values home.char.graph.edges, "edge edge-selected" )

            else
                ( List.Extra.filterNot (\e -> isEdgeSelected home e) <| Dict.values home.char.graph.edges, "edge" )

        path =
            edges
                |> List.map viewEdge
                |> String.join " "
    in
    S.path [ A.class classes, A.d path ] []


{-| Also old title-tooltip text.
-}
nodeSearchText : GameData.NodeType -> String
nodeSearchText val =
    val.name ++ appendSearch (GameData.tooltip val "" |> Just) ++ appendSearch val.flavorText


appendSearch =
    Maybe.Extra.unwrap "" ((++) "\n\n")


viewZoomButtons : { width : Int, height : Int } -> Svg Msg
viewZoomButtons w =
    S.g [ A.class "zoom-buttons" ]
        [ viewZoomButton ( w.width - 35, 5 ) "+" (Model.Zoom -25)
        , viewZoomButton ( w.width - 35, 35 ) "-" (Model.Zoom 25)
        ]


viewZoomButton : ( Int, Int ) -> String -> msg -> Svg msg
viewZoomButton ( x, y ) text msg =
    S.g [ E.onClick msg ]
        [ S.rect [ A.x (String.fromInt x), A.y (String.fromInt y), A.width "30", A.height "30", A.rx "5", A.ry "5" ] []
        , S.text_ [ A.x (String.fromInt <| x + 15), A.y (String.fromInt <| y + 15) ] [ S.text text ]
        ]


inputZoomAndPan : List (S.Attribute Msg)
inputZoomAndPan =
    [ handleZoom
    , Draggable.mouseTrigger () Model.DragMsg
    ]


panOffsets : Model -> GraphModel -> ( { width : Int, height : Int }, Float, Float )
panOffsets model graph =
    let
        ( w, sidebarXOffset ) =
            if model.sidebarOpen then
                ( { height = model.windowSize.height
                  , width = model.windowSize.width - sidebarWidth
                  }
                , sidebarWidth
                )

            else
                ( model.windowSize, 0 )

        c =
            Model.center { model | windowSize = w } graph |> V2.toRecord

        zoom =
            Model.zoom { model | windowSize = w } graph

        ( left, top ) =
            ( c.x - (toFloat w.width / 2 + sidebarXOffset) / zoom
            , c.y - toFloat w.height / 2 / zoom
            )
    in
    ( w, -left, -top )


sidebarWidth =
    480


zoomAndPan : Model -> GraphModel -> S.Attribute msg
zoomAndPan model graph =
    let
        ( w, panX, panY ) =
            panOffsets model graph

        zoom =
            Model.zoom { model | windowSize = w } graph

        panning =
            "translate(" ++ String.fromFloat panX ++ ", " ++ String.fromFloat panY ++ ")"

        zooming =
            "scale(" ++ String.fromFloat zoom ++ ")"
    in
    A.transform (zooming ++ " " ++ panning)


handleZoom : S.Attribute Msg
handleZoom =
    let
        event dy =
            { stopPropagation = True
            , preventDefault = True
            , message = normalizeMouseZoom dy
            }
    in
    VirtualDom.on
        "wheel"
        (Decode.field "deltaY" Decode.float |> Decode.map event |> VirtualDom.Custom)


normalizeMouseZoom : Float -> Model.Msg
normalizeMouseZoom deltaY =
    let
        normalized =
            if deltaY < 0 then
                -1

            else if deltaY > 0 then
                1

            else
                0

        speed =
            10
    in
    Model.Zoom <| normalized * speed


formatViewBox : Int -> GameData.Graph -> String
formatViewBox margin g =
    [ GameData.graphMinX g - margin, GameData.graphMinY g - margin, GameData.graphWidth g + 2 * margin, GameData.graphHeight g + 2 * margin ]
        |> List.map String.fromInt
        |> String.join " "


isEdgeSelected : GraphModel -> GameData.Edge -> Bool
isEdgeSelected home ( a, b ) =
    let
        aSelected =
            Set.member a.id home.selected

        bSelected =
            Set.member b.id home.selected
    in
    aSelected && bSelected


viewEdge : GameData.Edge -> String
viewEdge ( a, b ) =
    let
        startPoint =
            "M" ++ String.fromInt a.x ++ " " ++ String.fromInt a.y

        endPoint =
            "L" ++ String.fromInt b.x ++ " " ++ String.fromInt b.y
    in
    startPoint ++ " " ++ endPoint


iconSize =
    Model.nodeIconSize


nodeBGSize =
    iconSize * 4


viewNodeBackground : GraphModel -> GameData.Node -> Svg msg
viewNodeBackground { selected, search, neighbors } { id, x, y, val } =
    -- Backgrounds are drawn separately from the rest of the node, so they don't interfere with other nodes' clicks
    S.image
        [ A.class <|
            String.join " "
                [ "node-background"
                , nodeHighlightClass search val
                , nodeSelectedClass selected id
                , nodeNeighborClass neighbors id
                , View.Util.nodeQualityClass val.quality
                ]
        , A.xlinkHref <|
            View.Util.nodeBackgroundImage val
                { isHighlighted = isNodeHighlighted search val
                , isSelected = Set.member id selected
                , isNeighbor = Set.member id neighbors
                }
        , A.x <| String.fromInt <| x - nodeBGSize // 2
        , A.y <| String.fromInt <| y - nodeBGSize // 2
        , A.width <| String.fromInt nodeBGSize
        , A.height <| String.fromInt nodeBGSize
        ]
        []


viewNode : Route.Features -> GraphModel -> GameData.Node -> Svg Msg
viewNode features home { id, x, y, val } =
    S.g
        [ A.class <|
            String.join " "
                [ "node"
                , nodeHighlightClass home.search val
                , nodeSelectedClass home.selected id
                , nodeNeighborClass home.neighbors id
                , View.Util.nodeQualityClass val.quality
                ]
        , E.onMouseOver <| Model.NodeMouseOver id
        , E.onMouseOut <| Model.NodeMouseOut id

        -- , E.onMouseDown <| Model.NodeMouseDown id
        , E.on "mousedown" <| Decode.map (Model.NodeMouseDown id) ctrlKeyDecoder
        , E.onMouseUp <| Model.NodeMouseUp id
        , E.on "touchStart" <| Decode.succeed <| Model.NodeMouseDown id False
        , E.on "touchEnd" <| Decode.succeed <| Model.NodeMouseUp id
        ]
        [ S.image
            [ A.xlinkHref <| View.Util.nodeIconUrl val
            , A.x <| String.fromInt <| x - iconSize // 2
            , A.y <| String.fromInt <| y - iconSize // 2
            , A.width <| String.fromInt iconSize
            , A.height <| String.fromInt iconSize
            ]
            []
        ]


ctrlKeyDecoder : Decode.Decoder Bool
ctrlKeyDecoder =
    Decode.field "ctrlKey" Decode.bool


isNodeHighlighted : Maybe Regex -> GameData.NodeType -> Bool
isNodeHighlighted q0 t =
    Maybe.Extra.unwrap False (\q -> Regex.contains q <| nodeSearchText t) q0


{-| `(searches) (with) (subgroups)` can be highlighted different colors. Give each group a number.
-}
nodeHighlightGroup : Maybe Regex -> GameData.NodeType -> Maybe Int
nodeHighlightGroup regex0 t =
    let
        find regex =
            case nodeSearchText t |> Regex.findAtMost 1 regex of
                [] ->
                    Nothing

                { submatches } :: _ ->
                    submatches
                        |> List.indexedMap (\a b -> ( a, b ))
                        -- |> Debug.log ("nodeHighlightGroup match: " ++ t.name)
                        -- maximum 6 groups. ~~640k~~ 6 ought to be enough for anybody
                        |> List.filterMap (\( i, match ) -> match |> Maybe.map (always <| modBy 6 i))
                        |> List.head
                        -- it matched, but has no subgroups
                        |> Maybe.withDefault 0
                        |> Just
    in
    Maybe.Extra.unwrap Nothing find regex0


nodeHighlightClass : Maybe Regex -> GameData.NodeType -> String
nodeHighlightClass q t =
    case nodeHighlightGroup q t of
        Nothing ->
            "node-nohighlight"

        Just i ->
            "node-highlight node-highlight" ++ String.fromInt i


nodeSelectedClass : Set Int -> Int -> String
nodeSelectedClass selected id =
    if Set.member id selected then
        "node-selected"

    else
        "node-noselected"


nodeNeighborClass : Set Int -> Int -> String
nodeNeighborClass selected id =
    if Set.member id selected then
        "node-neighbor"

    else
        "node-nonneighbor"
