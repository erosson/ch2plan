module ViewGraph exposing (..)

import Dict as Dict exposing (Dict)
import Set as Set exposing (Set)
import Regex as Regex exposing (Regex)
import Html as H
import Html.Attributes as HA
import Svg as S
import Svg.Attributes as A
import Svg.Events as E
import Svg.Lazy as L
import Maybe.Extra
import Math.Vector2 as V2
import Draggable
import VirtualDom
import Json.Decode as Decode
import Window
import Model as M
import GameData as G
import Route


view : Window.Size -> M.HomeModel -> Route.Features -> H.Html M.Msg
view windowSize model features =
    -- svg-container is for tooltip positioning. It must be exactly the same size as the svg itself.
    H.div [ HA.class "svg-container" ]
        ([ S.svg
            inputZoomAndPan
            [ S.defs []
                -- hueSelected/hueSearch are gone now, but just in case we add multicolor searches later, here's a hint:
                -- S.filter [ A.id "hueSearch" ] [ S.feColorMatrix [ A.type_ "hueRotate", A.values <| toString hueSearch ]
                [ S.filter [ A.id "edge" ] [ S.feGaussianBlur [ A.in_ "SourceGraphic", A.stdDeviation "2" ] [] ]
                , S.filter [ A.id "edgeSelected" ] [ S.feGaussianBlur [ A.in_ "SourceGraphic", A.stdDeviation "4" ] [] ]
                ]
            , S.g [ zoomAndPan windowSize model ]
                ([ model.graph |> L.lazy viewEdges
                 , model.graph |> L.lazy viewNodeBackgrounds
                 , model.graph |> L.lazy2 viewNodes features
                 ]
                )
            , viewZoomButtons windowSize
            ]
         ]
            ++ Maybe.Extra.unwrap []
                (List.singleton << viewTooltip windowSize model)
                -- (model.tooltip |> Maybe.withDefault 1 |> Just |> Maybe.andThen ((flip Dict.get) model.char.graph.nodes))
                (Route.ifFeature features.fancyTooltips model.tooltip Nothing |> Maybe.andThen ((flip Dict.get) model.graph.char.graph.nodes))
        )


viewNodeBackgrounds : M.HomeGraphModel -> S.Svg msg
viewNodeBackgrounds home =
    let
        _ =
            Debug.log "redraw backgrounds" ()
    in
        home.char.graph.nodes |> Dict.toList |> List.map (viewNodeBackground home << Tuple.second) |> S.g []


viewNodes : Route.Features -> M.HomeGraphModel -> S.Svg M.Msg
viewNodes features home =
    let
        _ =
            Debug.log "redraw nodes" ()
    in
        home.char.graph.nodes |> Dict.toList |> List.map (viewNode features home << Tuple.second) |> S.g []


viewEdges : M.HomeGraphModel -> S.Svg msg
viewEdges home =
    let
        _ =
            Debug.log "redraw edges" ()
    in
        S.g [] (List.map (viewEdge home << Tuple.second) <| Dict.toList home.char.graph.edges)


viewTooltip : Window.Size -> M.HomeModel -> G.Node -> H.Html msg
viewTooltip win model node =
    -- no css-scaling here - tooltips don't scale with zoom.
    -- no svg here - svg can't word-wrap, and <foreignObject> has screwy browser support.
    --
    -- svg has no viewbox and the html container size == the svg size,
    -- so coordinates in both should match.
    let
        ( panX, panY ) =
            panOffsets win model

        ( w, h ) =
            ( toFloat win.width, toFloat win.height )

        ( x, y ) =
            ( (toFloat node.x + panX) * model.zoom, (toFloat node.y + panY) * model.zoom )

        style =
            [ if x > w / 2 then
                ( "right", w - x )
              else
                ( "left", x )
            , if y > h / 2 then
                ( "bottom", h - y )
              else
                ( "top", y )
            ]
                |> List.map (Tuple.mapSecond <| \n -> toString n ++ "px")
    in
        H.div [ HA.class "tooltip", HA.style style ]
            [ H.b [] [ H.text node.val.name ]
            , H.p [] [ H.text <| Maybe.withDefault "" node.val.tooltip ]
            , H.p [ A.class "flavor" ] [ H.text <| Maybe.withDefault "" node.val.flavorText ]
            ]


{-| Also old title-tooltip text.
-}
nodeSearchText : G.NodeType -> String
nodeSearchText val =
    val.name ++ appendSearch val.tooltip ++ appendSearch val.flavorText


appendSearch =
    Maybe.Extra.unwrap "" ((++) "\n\n")


viewZoomButtons : Window.Size -> S.Svg M.Msg
viewZoomButtons w =
    S.g [ A.class "zoom-buttons" ]
        [ viewZoomButton ( w.width - 35, 5 ) "+" (M.Zoom -25)
        , viewZoomButton ( w.width - 35, 35 ) "-" (M.Zoom 25)
        ]


viewZoomButton : ( Int, Int ) -> String -> msg -> S.Svg msg
viewZoomButton ( x, y ) text msg =
    S.g [ E.onClick msg ]
        [ S.rect [ A.x (toString x), A.y (toString y), A.width "30", A.height "30", A.rx "5", A.ry "5" ] []
        , S.text_ [ A.x (toString <| x + 15), A.y (toString <| y + 15) ] [ S.text text ]
        ]


inputZoomAndPan : List (S.Attribute M.Msg)
inputZoomAndPan =
    [ handleZoom
    , Draggable.mouseTrigger () M.DragMsg
    ]


panOffsets : Window.Size -> M.HomeModel -> ( Float, Float )
panOffsets w { center, zoom } =
    let
        ( cx, cy ) =
            V2.toTuple center

        ( left, top ) =
            ( cx - toFloat w.width / zoom / 2, cy - toFloat w.height / zoom / 2 )
    in
        ( -left, -top )


zoomAndPan : Window.Size -> M.HomeModel -> S.Attribute msg
zoomAndPan w model =
    let
        ( panX, panY ) =
            panOffsets w model

        panning =
            "translate(" ++ toString panX ++ ", " ++ toString panY ++ ")"

        zooming =
            "scale(" ++ toString model.zoom ++ ")"
    in
        A.transform (zooming ++ " " ++ panning)


handleZoom : S.Attribute M.Msg
handleZoom =
    let
        ignoreDefaults =
            VirtualDom.Options True True
    in
        VirtualDom.onWithOptions
            "wheel"
            ignoreDefaults
            (Decode.map normalizeMouseZoom <| Decode.field "deltaY" Decode.float)


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
        |> List.map toString
        |> String.join " "


viewEdge : M.HomeGraphModel -> G.Edge -> S.Svg msg
viewEdge home ( a, b ) =
    let
        -- the SVG blur filter does not work on vertical or horizontal lines. Ugh.
        -- To work around this, don't draw the line between a and b. Instead, draw
        -- a line of the same length at 45 degrees - a square diagonal - and
        -- transform it to the correct angle. What a pain.
        ( ax, ay, bx, by ) =
            ( toFloat a.x, toFloat a.y, toFloat b.x, toFloat b.y )

        ( length, radians ) =
            toPolar ( ax - bx, ay - by )

        ( x2, y2 ) =
            -- a diagonal line. Workaround svg filter problem below.
            fromPolar ( length, pi / 4 )
                |> \( dx, dy ) -> ( ax + dx, ay + dy )

        transformDegrees =
            -- transform the 45% angle back to the original angle
            radians
                - (pi / 4)
                |> (+) pi
                -- svg insists on degrees, not radians
                |> (*) (180 / pi)
    in
        S.line
            [ A.x1 <| toString ax
            , A.y1 <| toString ay

            -- , A.x2 <| toString <| b.x + 1
            -- , A.y2 <| toString <| b.y + 1
            , A.x2 <| toString x2
            , A.y2 <| toString y2
            , A.transform <| "rotate(" ++ (String.join " " <| List.map toString [ transformDegrees, ax, ay ]) ++ ")"
            , A.class <|
                String.join " " <|
                    [ "edge"
                    , if Set.member a.id home.selected && Set.member b.id home.selected then
                        "edge-selected"
                      else
                        "edge-unselected"
                    ]
            ]
            []


nodeQualityClass : G.NodeQuality -> String
nodeQualityClass =
    toString >> (++) "node-"


iconSize =
    50


nodeBGSize =
    iconSize * 4


iconUrl : G.NodeType -> String
iconUrl node =
    "./ch2data/img/" ++ node.icon ++ ".png"


viewNodeBackground : M.HomeGraphModel -> G.Node -> S.Svg msg
viewNodeBackground { selected, search, neighbors } { id, x, y, val } =
    -- Backgrounds are drawn separately from the rest of the node, so they don't interfere with other nodes' clicks
    S.image
        [ A.class <| String.join " " [ "node-background", nodeHighlightClass search val, nodeSelectedClass selected id, nodeNeighborClass neighbors id, nodeQualityClass val.quality ]
        , A.xlinkHref <| nodeBackgroundImage val (isNodeHighlighted search val) (Set.member id selected) (Set.member id neighbors)
        , A.x <| toString <| x - nodeBGSize // 2
        , A.y <| toString <| y - nodeBGSize // 2
        , A.width <| toString nodeBGSize
        , A.height <| toString nodeBGSize
        ]
        []


viewNode : Route.Features -> M.HomeGraphModel -> G.Node -> S.Svg M.Msg
viewNode features home { id, x, y, val } =
    S.g
        [ A.class <| String.join " " [ "node", nodeHighlightClass home.search val, nodeSelectedClass home.selected id, nodeNeighborClass home.neighbors id, nodeQualityClass val.quality ]
        , E.onMouseOver <| M.Tooltip <| Just id
        , E.onMouseOut <| M.Tooltip Nothing
        ]
        ([ S.image
            [ A.xlinkHref <| iconUrl val
            , A.x <| toString <| x - iconSize // 2
            , A.y <| toString <| y - iconSize // 2
            , A.width <| toString iconSize
            , A.height <| toString iconSize
            , E.onClick <| M.SelectInput id
            ]
            []
         ]
            ++ Route.ifFeature features.fancyTooltips [] [ S.title [] [ S.text <| nodeSearchText val ] ]
        )


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


nodeHighlightClass : Maybe Regex -> G.NodeType -> String
nodeHighlightClass q t =
    if isNodeHighlighted q t then
        "node-highlight"
    else
        "node-nohighlight"


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
