module View exposing (view)

import Dict as Dict exposing (Dict)
import Set as Set exposing (Set)
import Html as H
import Html.Attributes as A
import Html.Events as E
import Model as M
import GameData as G
import ViewGraph


view : M.Model -> H.Html M.Msg
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
            , viewSearch model
            , ViewGraph.view model g
            , viewSearch model

            -- debug data
            , H.ul [] (List.map (H.li [] << List.singleton << uncurry viewNodeType) <| Dict.toList c.nodeTypes)
            , dumpModel model
            ]


viewSearch : M.Model -> H.Html M.Msg
viewSearch { selected, search } =
    H.div []
        [ H.div [] [ H.text <| toString (Set.size selected) ++ " points spent." ]
        , H.div []
            [ H.text "Highlight: "
            , H.input [ A.type_ "text", A.value <| Maybe.withDefault "" search, E.onInput M.SearchInput ] []
            ]
        ]


viewNodeType : String -> G.NodeType -> H.Html msg
viewNodeType key nodetype =
    H.text <| key ++ ": " ++ toString nodetype


dumpModel : M.Model -> H.Html msg
dumpModel =
    H.text << toString
