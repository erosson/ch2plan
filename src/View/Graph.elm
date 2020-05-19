module View.Graph exposing
    ( iconUrl
    , nodeBackgroundImage
    , nodeQualityClass
    , view
    )

import Dict as Dict exposing (Dict)
import Draggable
import GameData as G
import Html as H
import Html.Attributes as HA
import Json.Decode as Decode
import List.Extra
import Math.Vector2 as V2
import Maybe.Extra
import Model as M
import Model.Graph as MG
import Regex as Regex exposing (Regex)
import Route
import Set as Set exposing (Set)
import Svg as S
import Svg.Attributes as A
import Svg.Events as E
import Svg.Lazy as L
import VirtualDom


view : M.Model -> MG.GraphModel -> H.Html M.Msg
view model graph =
    -- svg-container is for tooltip positioning. It must be exactly the same size as the svg itself.
    H.div [ HA.class "svg-container" ]
        ([ S.svg
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
         ]
            ++ Maybe.Extra.unwrap []
                (List.singleton << viewTooltip model graph)
                (M.visibleTooltip model |> Maybe.andThen ((\b a -> Dict.get a b) graph.char.graph.nodes))
        )


debug : String -> ()
debug s =
    -- Uncomment this to diagnose redraw/lag problems
    -- Debug.log s ()
    ()


viewNodeBackgrounds : MG.GraphModel -> S.Svg msg
viewNodeBackgrounds home =
    let
        _ =
            debug "redraw backgrounds"
    in
    home.char.graph.nodes |> Dict.toList |> List.map (viewNodeBackground home << Tuple.second) |> S.g []


viewNodes : Route.Features -> MG.GraphModel -> S.Svg M.Msg
viewNodes features home =
    let
        _ =
            debug "redraw nodes"
    in
    home.char.graph.nodes |> Dict.toList |> List.map (viewNode features home << Tuple.second) |> S.g []


viewEdges : Bool -> MG.GraphModel -> S.Svg msg
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


viewTooltip : M.Model -> MG.GraphModel -> G.Node -> H.Html msg
viewTooltip model graph node =
    -- no css-scaling here - tooltips don't scale with zoom.
    -- no svg here - svg can't word-wrap, and <foreignObject> has screwy browser support.
    --
    -- svg has no viewbox and the html container size == the svg size,
    -- so coordinates in both should match.
    let
        ( win, panX, panY ) =
            panOffsets model graph

        ( w, h ) =
            ( toFloat win.width, toFloat win.height )

        zoom =
            M.zoom { model | windowSize = win } graph

        ( x, y ) =
            ( (toFloat node.x + panX) * zoom, (toFloat node.y + panY) * zoom )

        sidebarOffset =
            if model.sidebarOpen then
                sidebarWidth

            else
                0

        style =
            [ if x > sidebarOffset + w / 2 then
                ( "right", sidebarOffset + w - x )

              else
                ( "left", x )
            , if y > h / 2 then
                ( "bottom", h - y )

              else
                ( "top", y )
            ]
                |> List.map (Tuple.mapSecond <| \n -> String.fromFloat n ++ "px")
                |> List.map (\( k, v ) -> HA.style k v)
    in
    H.div ([ HA.class "tooltip" ] ++ style)
        [ H.b [] [ H.text node.val.name ]
        , H.p [] [ H.text <| G.tooltip node.val "" ]
        , H.p [ A.class "flavor" ] [ H.text <| Maybe.withDefault "" node.val.flavorText ]
        , H.p [ A.class "flammable" ]
            (if node.val.flammable then
                [ H.text "Flammable: The effects of this node will be lost when you choose to Ascend or Transcend" ]

             else
                []
            )
        ]


{-| Also old title-tooltip text.
-}
nodeSearchText : G.NodeType -> String
nodeSearchText val =
    val.name ++ appendSearch (G.tooltip val "" |> Just) ++ appendSearch val.flavorText


appendSearch =
    Maybe.Extra.unwrap "" ((++) "\n\n")


viewZoomButtons : { width : Int, height : Int } -> S.Svg M.Msg
viewZoomButtons w =
    S.g [ A.class "zoom-buttons" ]
        [ viewZoomButton ( w.width - 35, 5 ) "+" (M.Zoom -25)
        , viewZoomButton ( w.width - 35, 35 ) "-" (M.Zoom 25)
        ]


viewZoomButton : ( Int, Int ) -> String -> msg -> S.Svg msg
viewZoomButton ( x, y ) text msg =
    S.g [ E.onClick msg ]
        [ S.rect [ A.x (String.fromInt x), A.y (String.fromInt y), A.width "30", A.height "30", A.rx "5", A.ry "5" ] []
        , S.text_ [ A.x (String.fromInt <| x + 15), A.y (String.fromInt <| y + 15) ] [ S.text text ]
        ]


inputZoomAndPan : List (S.Attribute M.Msg)
inputZoomAndPan =
    [ handleZoom
    , Draggable.mouseTrigger () M.DragMsg
    ]


panOffsets : M.Model -> MG.GraphModel -> ( { width : Int, height : Int }, Float, Float )
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
            M.center { model | windowSize = w } graph |> V2.toRecord

        zoom =
            M.zoom { model | windowSize = w } graph

        ( left, top ) =
            ( c.x - (toFloat w.width / 2 + sidebarXOffset) / zoom
            , c.y - toFloat w.height / 2 / zoom
            )
    in
    ( w, -left, -top )


sidebarWidth =
    480


zoomAndPan : M.Model -> MG.GraphModel -> S.Attribute msg
zoomAndPan model graph =
    let
        ( w, panX, panY ) =
            panOffsets model graph

        zoom =
            M.zoom { model | windowSize = w } graph

        panning =
            "translate(" ++ String.fromFloat panX ++ ", " ++ String.fromFloat panY ++ ")"

        zooming =
            "scale(" ++ String.fromFloat zoom ++ ")"
    in
    A.transform (zooming ++ " " ++ panning)


handleZoom : S.Attribute M.Msg
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


normalizeMouseZoom : Float -> M.Msg
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
    M.Zoom <| normalized * speed


formatViewBox : Int -> G.Graph -> String
formatViewBox margin g =
    [ G.graphMinX g - margin, G.graphMinY g - margin, G.graphWidth g + 2 * margin, G.graphHeight g + 2 * margin ]
        |> List.map String.fromInt
        |> String.join " "


isEdgeSelected : MG.GraphModel -> G.Edge -> Bool
isEdgeSelected home ( a, b ) =
    let
        aSelected =
            Set.member a.id home.selected

        bSelected =
            Set.member b.id home.selected
    in
    aSelected && bSelected


viewEdge : G.Edge -> String
viewEdge ( a, b ) =
    let
        startPoint =
            "M" ++ String.fromInt a.x ++ " " ++ String.fromInt a.y

        endPoint =
            "L" ++ String.fromInt b.x ++ " " ++ String.fromInt b.y
    in
    startPoint ++ " " ++ endPoint


nodeQualityClass : G.NodeQuality -> String
nodeQualityClass =
    G.qualityToString >> (++) "node-"


iconSize =
    M.nodeIconSize


nodeBGSize =
    iconSize * 4


iconUrl : G.NodeType -> String
iconUrl node =
    "./ch2data/img/" ++ Maybe.withDefault "404" node.icon ++ ".png"


viewNodeBackground : MG.GraphModel -> G.Node -> S.Svg msg
viewNodeBackground { selected, search, neighbors } { id, x, y, val } =
    -- Backgrounds are drawn separately from the rest of the node, so they don't interfere with other nodes' clicks
    S.image
        [ A.class <| String.join " " [ "node-background", nodeHighlightClass search val, nodeSelectedClass selected id, nodeNeighborClass neighbors id, nodeQualityClass val.quality ]
        , A.xlinkHref <| nodeBackgroundImage val (isNodeHighlighted search val) (Set.member id selected) (Set.member id neighbors)
        , A.x <| String.fromInt <| x - nodeBGSize // 2
        , A.y <| String.fromInt <| y - nodeBGSize // 2
        , A.width <| String.fromInt nodeBGSize
        , A.height <| String.fromInt nodeBGSize
        ]
        []


viewNode : Route.Features -> MG.GraphModel -> G.Node -> S.Svg M.Msg
viewNode features home { id, x, y, val } =
    S.g
        [ A.class <| String.join " " [ "node", nodeHighlightClass home.search val, nodeSelectedClass home.selected id, nodeNeighborClass home.neighbors id, nodeQualityClass val.quality ]
        , E.onMouseOver <| M.NodeMouseOver id
        , E.onMouseOut <| M.NodeMouseOut id
        , E.onMouseDown <| M.NodeMouseDown id
        , E.onMouseUp <| M.NodeMouseUp id
        , E.on "touchStart" <| Decode.succeed <| M.NodeMouseDown id
        , E.on "touchEnd" <| Decode.succeed <| M.NodeMouseUp id
        ]
        [ S.image
            [ A.xlinkHref <| iconUrl val
            , A.x <| String.fromInt <| x - iconSize // 2
            , A.y <| String.fromInt <| y - iconSize // 2
            , A.width <| String.fromInt iconSize
            , A.height <| String.fromInt iconSize
            ]
            []
        ]


nodeBackgroundImage : G.NodeType -> Bool -> Bool -> Bool -> String
nodeBackgroundImage node isHighlighted isSelected isNeighbor =
    let
        quality =
            case node.quality of
                G.Keystone ->
                    "deluxeNode"

                G.Notable ->
                    "specialNode"

                G.Plain ->
                    "generalNode"

        suffix =
            if isHighlighted then
                "Highlight"

            else if isSelected then
                -- SelectedVis has a green border, while Selected is just like in-game.
                -- Small nodes aren't visible enough when selected - too small,
                -- not enough color; in-game they're animated so it's more visible -
                -- so give them the border. Other nodes are visible enough without
                -- the extra border - much larger, with more color - so leave them alone.
                if node.quality == G.Plain then
                    "SelectedVis"

                else
                    "Selected"

            else if isNeighbor then
                "Next"

            else
                ""
    in
    "./ch2data/node-img/" ++ quality ++ suffix ++ ".png?3"


isNodeHighlighted : Maybe Regex -> G.NodeType -> Bool
isNodeHighlighted q0 t =
    Maybe.Extra.unwrap False (\q -> Regex.contains q <| nodeSearchText t) q0


{-| `(searches) (with) (subgroups)` can be highlighted different colors. Give each group a number.
-}
nodeHighlightGroup : Maybe Regex -> G.NodeType -> Maybe Int
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


nodeHighlightClass : Maybe Regex -> G.NodeType -> String
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
