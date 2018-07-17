module ViewGraph exposing (..)

import Dict as Dict exposing (Dict)
import Regex as Regex exposing (Regex)
import Html as H
import Html.Attributes as HA
import Svg as S
import Svg.Attributes as A
import Maybe.Extra
import Model as M
import GameData as G


view : M.Model -> G.Graph -> H.Html msg
view { search } g =
    S.svg [ HA.style [ ( "border", "1px solid grey" ) ], A.viewBox <| formatViewBox 30 g ]
        [ S.g [] (List.map (viewEdge << Tuple.second) <| Dict.toList g.edges)
        , S.g [] (List.map (viewNode (Maybe.map (Regex.regex >> Regex.caseInsensitive) search) << Tuple.second) <| Dict.toList g.nodes)
        ]


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


viewNode : Maybe Regex -> G.Node -> S.Svg msg
viewNode q { x, y, val } =
    S.circle
        [ A.cx <| toString x
        , A.cy <| toString y
        , A.r "30"
        , A.class <| String.join " " [ "node", nodeHighlightClass q val ]
        ]
        [ S.title [] [ S.text <| nodeTooltipText val ] ]


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
