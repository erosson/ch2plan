module ViewSkillTree exposing (view)

import Dict as Dict exposing (Dict)
import Set as Set exposing (Set)
import Html as H
import Html.Attributes as A
import Html.Events as E
import Maybe.Extra
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
            [ H.h4 [] [ H.text <| c.name ++ ": " ++ c.flavorName ++ ", " ++ c.flavorClass ]
            , H.p [] [ H.text <| c.flavor ]
            , viewSearch model
            , ViewGraph.view model g
            , viewSearch model

            -- debug data
            -- , H.ul [] (List.map (H.li [] << List.singleton << uncurry viewNodeType) <| Dict.toList c.nodeTypes)
            -- , dumpModel model
            , viewSummary <| M.summary model
            , H.p [] [ H.text <| "Last updated: " ++ model.lastUpdatedVersion ]
            ]


viewSearch : M.Model -> H.Html M.Msg
viewSearch model =
    H.div []
        [ H.div [] [ H.text <| toString (Set.size <| M.selectedNodes model) ++ " points spent." ]
        , H.div []
            [ H.text "Highlight: "
            , H.input [ A.type_ "text", A.value <| Maybe.withDefault "" model.search, E.onInput M.SearchInput ] []
            ]
        ]


viewNodeType : String -> G.NodeType -> H.Html msg
viewNodeType key nodetype =
    H.text <| key ++ ": " ++ toString nodetype


viewSummary : List ( Int, G.NodeType ) -> H.Html msg
viewSummary ns =
    H.div [ A.class "summary" ] <|
        if List.length ns == 0 then
            []
        else
            [ H.p [] [ H.text "Build summary: " ]
            , H.ul [] (List.map (uncurry viewSummaryLine) ns)
            ]


viewSummaryLine : Int -> G.NodeType -> H.Html msg
viewSummaryLine count nodeType =
    H.li []
        [ H.div [ A.class <| String.join " " [ "icon", ViewGraph.nodeQualityClass nodeType.quality ] ]
            [ H.img [ A.src <| ViewGraph.iconUrl nodeType ] []
            , H.div [ A.class "overlay" ] []
            ]
        , H.div []
            [ H.text <|
                " "
                    ++ if count /= 1 then
                        toString count ++ "x "
                       else
                        ""
            , H.b [] [ H.text nodeType.name ]
            , H.span [] [ H.text <| Maybe.Extra.unwrap "" ((++) ": ") nodeType.tooltip ]
            ]

        -- , H.div [] [ H.text <| Maybe.withDefault "" nodeType.tooltip ]
        , H.div [ A.class "clear" ] []

        -- , H.text <| toString nodeType
        ]


dumpModel : M.Model -> H.Html msg
dumpModel =
    H.text << toString
