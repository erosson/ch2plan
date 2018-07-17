module View exposing (view)

import Dict as Dict exposing (Dict)
import Html as H
import Model as M
import GameData as G
import ViewGraph


view : M.Model -> H.Html msg
view model =
    let
        c =
            model.characterData

        g =
            G.graph c
    in
        H.div []
            [ H.h2 [] [ H.text "Clicker Heroes 2 Skill Tree Planner" ]
            , H.h4 [] [ H.text <| c.name ++ ": " ++ c.flavorName ++ ", " ++ c.flavorClass ]
            , H.p [] [ H.text <| c.flavor ]
            , ViewGraph.view g

            -- debug data
            , H.ul [] (List.map (H.li [] << List.singleton << uncurry viewNodeType) <| Dict.toList c.nodeTypes)
            , dumpModel model
            ]


viewNodeType : String -> G.NodeType -> H.Html msg
viewNodeType key nodetype =
    H.text <| key ++ ": " ++ toString nodetype


dumpModel : M.Model -> H.Html msg
dumpModel =
    H.text << toString
