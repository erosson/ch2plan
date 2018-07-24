module ViewGraph exposing (..)

import Dict as Dict exposing (Dict)
import Set as Set exposing (Set)
import Regex as Regex exposing (Regex)
import Html as H
import Html.Attributes as HA
import Svg as S
import Svg.Attributes as A
import Svg.Events as E
import Maybe.Extra
import Math.Vector2 as V2
import Draggable
import VirtualDom
import Json.Decode as Decode
import Model as M
import GameData as G
import Route


view : M.HomeModel -> Route.Features -> H.Html M.Msg
view model features =
    let
        (( w, h ) as wh) =
            ( 1000, 1000 )

        selectable =
            M.selectableNodes M.startNodes model.char.graph model.selected

        style =
            [ ( "width", toString w ++ "px" ), ( "height", toString h ++ "px" ) ]
    in
        -- svg-container is for tooltip positioning. It must be exactly the same size as the svg itself.
        H.div [ HA.class "svg-container", HA.style style ]
            ([ S.svg
                ([ HA.style style
                 ]
                    ++ Route.ifFeature features.zoom
                        inputZoomAndPan
                        [ A.viewBox <| formatViewBox (iconSize // 2) model.char.graph ]
                )
                [ S.g (Route.ifFeature features.zoom [ zoomAndPan wh model ] [])
                    ([ S.g [] (List.map (viewNodeBackground model.selected selectable model.search << Tuple.second) <| Dict.toList model.char.graph.nodes)
                     , S.g [] (List.map (viewEdge << Tuple.second) <| Dict.toList model.char.graph.edges)
                     , S.g [] (List.map (viewNode features model.selected selectable model.search << Tuple.second) <| Dict.toList model.char.graph.nodes)
                     ]
                    )
                , (Route.ifFeature features.zoom viewZoomButtons <| S.g [] [])
                ]
             ]
                ++ Maybe.Extra.unwrap []
                    (List.singleton << viewTooltip wh model)
                    -- (model.tooltip |> Maybe.withDefault 1 |> Just |> Maybe.andThen ((flip Dict.get) model.char.graph.nodes))
                    (Route.ifFeature features.fancyTooltips model.tooltip Nothing |> Maybe.andThen ((flip Dict.get) model.char.graph.nodes))
            )


viewTooltip : ( Float, Float ) -> M.HomeModel -> G.Node -> H.Html msg
viewTooltip (( w, h ) as wh) model node =
    -- no css-scaling here - tooltips don't scale with zoom.
    -- no svg here - svg can't word-wrap, and <foreignObject> has screwy browser support.
    --
    -- svg has no viewbox and the html container size == the svg size,
    -- so coordinates in both should match.
    let
        ( panX, panY ) =
            panOffsets wh model

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


viewZoomButtons : S.Svg M.Msg
viewZoomButtons =
    S.g [ A.class "zoom-buttons" ]
        [ viewZoomButton ( 5, 5 ) "+" (M.Zoom -25)
        , viewZoomButton ( 5, 35 ) "-" (M.Zoom 25)
        ]


viewZoomButton : ( Int, Int ) -> String -> msg -> S.Svg msg
viewZoomButton ( x, y ) text msg =
    S.g [ E.onClick msg ]
        [ S.rect [ A.x (toString x), A.y (toString y), A.width "30", A.height "30", A.rx "5", A.ry "5" ] []
        , S.text_ [ A.x (toString <| x + 15), A.y (toString <| y + 15) ] [ S.text text ]
        ]


inputZoomAndPan : List (S.Attribute M.Msg)
inputZoomAndPan =
    [ handleZoom M.Zoom
    , Draggable.mouseTrigger () M.DragMsg
    ]


panOffsets : ( Float, Float ) -> M.HomeModel -> ( Float, Float )
panOffsets ( w, h ) { center, zoom } =
    let
        ( cx, cy ) =
            V2.toTuple center

        ( left, top ) =
            ( cx - w / zoom / 2, cy - h / zoom / 2 )
    in
        ( -left, -top )


zoomAndPan : ( Float, Float ) -> M.HomeModel -> S.Attribute msg
zoomAndPan wh model =
    let
        ( panX, panY ) =
            panOffsets wh model

        panning =
            "translate(" ++ toString panX ++ ", " ++ toString panY ++ ")"

        zooming =
            "scale(" ++ toString model.zoom ++ ")"
    in
        A.transform (zooming ++ " " ++ panning)


handleZoom : (Float -> msg) -> S.Attribute msg
handleZoom onZoom =
    let
        ignoreDefaults =
            VirtualDom.Options True True
    in
        VirtualDom.onWithOptions
            "wheel"
            ignoreDefaults
            (Decode.map onZoom <| Decode.field "deltaY" Decode.float)


formatViewBox : Int -> G.Graph -> String
formatViewBox margin g =
    [ G.graphMinX g - margin, G.graphMinY g - margin, G.graphWidth g + 2 * margin, G.graphHeight g + 2 * margin ]
        |> List.map toString
        |> String.join " "


viewEdge : G.Edge -> S.Svg msg
viewEdge ( a, b ) =
    S.line [ A.x1 <| toString a.x, A.y1 <| toString a.y, A.x2 <| toString b.x, A.y2 <| toString b.y, A.class "edge" ] []


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


viewNodeBackground : Set Int -> Set Int -> Maybe Regex -> G.Node -> S.Svg M.Msg
viewNodeBackground selected selectable q { id, x, y, val } =
    -- Backgrounds are drawn separately from the rest of the node, so they don't interfere with other nodes' clicks
    S.image
        [ A.class <| String.join " " [ "node-background", nodeHighlightClass q val, nodeSelectedClass selected id, nodeSelectableClass selectable id, nodeQualityClass val.quality ]
        , A.xlinkHref <| nodeBackgroundImage val (isNodeHighlighted q val) (Set.member id selected) (Set.member id selectable)
        , A.x <| toString <| x - nodeBGSize // 2
        , A.y <| toString <| y - nodeBGSize // 2
        , A.width <| toString nodeBGSize
        , A.height <| toString nodeBGSize
        ]
        []


viewNode : Route.Features -> Set Int -> Set Int -> Maybe Regex -> G.Node -> S.Svg M.Msg
viewNode features selected selectable q { id, x, y, val } =
    S.g
        [ A.class <| String.join " " [ "node", nodeHighlightClass q val, nodeSelectedClass selected id, nodeSelectableClass selectable id, nodeQualityClass val.quality ]
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
nodeBackgroundImage node isHighlighted isSelected isSelectable =
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
            else if isSelectable then
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


nodeSelectableClass : Set Int -> Int -> String
nodeSelectableClass selected id =
    if Set.member id selected then
        "node-selectable"
    else
        "node-noselectable"
