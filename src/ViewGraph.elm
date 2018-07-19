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


view : M.Model -> G.Graph -> H.Html M.Msg
view model g =
    let
        searchRegex =
            Maybe.map (Regex.regex >> Regex.caseInsensitive) model.search

        selected =
            M.selectedNodes model

        selectable =
            M.selectableNodes M.startNodes g selected

        ( cx, cy ) =
            ( V2.getX model.center, V2.getY model.center )

        ( halfWidth, halfHeight ) =
            ( V2.getX model.size / model.zoom / 2, V2.getY model.size / model.zoom / 2 )

        ( top, left, bottom, right ) =
            ( cy - halfHeight, cx - halfWidth, cy + halfHeight, cx + halfWidth )

        panning =
            "translate(" ++ toString -left ++ ", " ++ toString -top ++ ")"

        zooming =
            "scale(" ++ toString model.zoom ++ ")"
    in
        S.svg
            [ HA.style [ ( "border", "1px solid grey" ) ]
            , A.viewBox <| formatViewBox 30 g

            --, A.width <| toString (V2.getX model.size)
            --, A.height <| toString (V2.getY model.size)
            , handleZoom M.Zoom
            , Draggable.mouseTrigger () M.DragMsg
            ]
            [ S.g [ A.transform (zooming ++ " " ++ panning) ] (List.map (viewEdge << Tuple.second) <| Dict.toList g.edges)
            , S.g [ A.transform (zooming ++ " " ++ panning) ] (List.map (viewNode selected selectable searchRegex << Tuple.second) <| Dict.toList g.nodes)
            ]


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


appendTooltip =
    Maybe.Extra.unwrap "" ((++) "\n\n")


viewNodeCircle : Set Int -> Set Int -> Maybe Regex -> G.Node -> S.Svg M.Msg
viewNodeCircle selected selectable q { id, x, y, val } =
    S.circle
        [ A.cx <| toString x
        , A.cy <| toString y
        , A.r <| toString <| iconSize / 2
        , A.class <| String.join " " [ "node", nodeHighlightClass q val, nodeSelectedClass selected id, nodeSelectableClass selectable id, nodeQualityClass val.quality ]
        , E.onClick <| M.SelectInput id
        ]
        [ S.title [] [ S.text <| nodeTooltipText val ] ]


nodeQualityClass : G.NodeQuality -> String
nodeQualityClass =
    toString >> (++) "node-"


iconSize =
    60


viewNode =
    viewNodeIcon


iconUrl : G.NodeType -> String
iconUrl node =
    "./ch2data/img/" ++ node.icon ++ ".png"


viewNodeIcon : Set Int -> Set Int -> Maybe Regex -> G.Node -> S.Svg M.Msg
viewNodeIcon selected selectable q { id, x, y, val } =
    S.g
        [ A.class <| String.join " " [ "node", nodeHighlightClass q val, nodeSelectedClass selected id, nodeSelectableClass selectable id, nodeQualityClass val.quality ]
        , E.onClick <| M.SelectInput id
        ]
        [ S.title [] [ S.text <| nodeTooltipText val ]
        , S.image
            [ A.xlinkHref <| iconUrl val
            , A.x <| toString <| x - iconSize // 2
            , A.y <| toString <| y - iconSize // 2
            , A.width <| toString iconSize
            , A.height <| toString iconSize
            ]
            []

        {- , S.circle
           [ A.cx <| toString x
           , A.cy <| toString y
           , A.r <| toString <| iconSize / 2
           , A.class "overlay"
           ]
           []
        -}
        , S.rect
            [ A.x <| toString <| x - iconSize // 2
            , A.y <| toString <| y - iconSize // 2
            , A.width <| toString iconSize
            , A.height <| toString iconSize
            , A.class "overlay"
            ]
            []
        ]


nodeTooltipText : G.NodeType -> String
nodeTooltipText val =
    val.name ++ appendTooltip val.tooltip ++ appendTooltip val.flavorText


isNodeHighlighted : Maybe Regex -> G.NodeType -> Bool
isNodeHighlighted q0 t =
    Maybe.Extra.unwrap False (\q -> Regex.contains q <| nodeTooltipText t) q0


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
