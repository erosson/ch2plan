module Model.Graph exposing
    (  GraphModel
       -- select

    , nodesToBuild
    , parse
    ,  reachableSelectedNodes
       -- create/update

    , search
    , updateOnChange
    )

import Dict as Dict exposing (Dict)
import GameData as G
import Lazy as Lazy exposing (Lazy)
import Maybe.Extra
import Model.Dijkstra as Dijkstra
import Ports
import Regex as Regex exposing (Regex)
import Route as Route exposing (Route)
import Set as Set exposing (Set)


{-| All information needed to efficiently render the skill tree graph.

This is separate from Model to allow efficiently re-rendering with Svg.Lazy,
which cares about referential equality in a way nothing else in Elm does.
Updating this object means the graph will be redrawn - but if this object isn't
updated, as when zooming/panning, we can efficiently skip that step. Normally
the Right Way/the Elm Way to do this is to put it all this in Model and
manipulate it with extensible records, but redrawing the edges and nodes is
slow enough that deviating from the Right Way to avoid it really is worth the
trouble.

-}
type alias GraphModel =
    { game : G.GameVersionData
    , char : G.Character
    , search : Maybe Regex
    , selected : Set G.NodeId
    , neighbors : Set G.NodeId
    , dijkstra : Lazy Dijkstra.Result
    }


create : G.GameVersionData -> G.Character -> Set G.NodeId -> GraphModel
create game char selected =
    { game = game
    , char = char
    , search = Nothing -- this has its own message, parsed in js for https://github.com/erosson/ch2plan/issues/44
    , selected = selected
    , neighbors = neighborNodes char.graph selected
    , dijkstra = Lazy.lazy (\() -> runDijkstra char.graph selected)
    }


runDijkstra graph selected =
    -- let
    -- _ =
    -- Debug.log "running dijkstra" ()
    -- in
    Dijkstra.dijkstra graph selected Nothing


neighborNodes : G.Graph -> Set G.NodeId -> Set G.NodeId
neighborNodes graph selected =
    Set.foldr (\id res -> G.neighbors id graph |> Set.union res) (G.startNodes graph) selected
        |> (\res -> Set.diff res selected)


nodesToBuild : G.Graph -> Set G.NodeId -> Maybe String
nodesToBuild graph =
    Set.toList
        >> List.map String.fromInt
        >> String.join "&"
        >> (\s ->
                if s == "" then
                    Nothing

                else
                    Just s
           )


buildToNodes : G.Graph -> Maybe String -> Result String (Set G.NodeId)
buildToNodes graph build =
    let
        strList =
            build |> Maybe.withDefault "" |> String.split "&"

        idList =
            -- non-ints are ignored. TODO: maybe we should error for these
            strList |> List.map String.toInt |> Maybe.Extra.values

        ids =
            idList |> Set.fromList
    in
    if strList == [ "all" ] then
        -- special-case a build with all nodes selected, "all"
        Ok <| allSelectableNodes graph

    else if List.length idList /= Set.size ids then
        Err "can't select a node twice"

    else if not <| isValidSelection graph ids then
        Err "some nodes in this build aren't connected to the start location"

    else
        Ok ids


{-| Remove any selected nodes that can't be reached from the start location.
-}
reachableSelectedNodes : G.Graph -> Set G.NodeId -> Set G.NodeId
reachableSelectedNodes graph selected =
    let
        loop : G.NodeId -> { reachable : Set G.NodeId, tried : Set G.NodeId } -> { reachable : Set G.NodeId, tried : Set G.NodeId }
        loop id res =
            if Set.member id res.tried then
                res

            else
                let
                    -- loop with all selected immediate neighbors
                    nextIds =
                        G.neighbors id graph |> Set.intersect selected
                in
                Set.foldr loop { tried = Set.insert id res.tried, reachable = Set.union res.reachable nextIds } nextIds

        startReachable =
            graph |> G.startNodes |> Set.intersect selected
    in
    Set.foldr loop { tried = Set.empty, reachable = startReachable } startReachable
        |> .reachable


allSelectableNodes : G.Graph -> Set G.NodeId
allSelectableNodes graph =
    graph.nodes
        |> Dict.keys
        |> Set.fromList
        |> reachableSelectedNodes graph


isValidSelection : G.Graph -> Set G.NodeId -> Bool
isValidSelection graph selected =
    reachableSelectedNodes graph selected == selected


search : String -> GraphModel -> GraphModel
search str model =
    { model
        | search =
            str
                |> Regex.fromStringWith { caseInsensitive = True, multiline = True }
    }


{-| Parse graph state from a route.

Return type here is a bit weird. We can have two kinds of errors:

  - total failures: the skill tree cannot be rendered at all. Bad game-version, bad hero-name.
  - partial failure: the skill tree _can_ be rendered, but there's a problem. Bad search, bad node selections.

-}
parse : G.GameData -> Route.HomeParams -> Result String ( GraphModel, Maybe String )
parse gameData q =
    case Dict.get q.version gameData.byVersion of
        Nothing ->
            Err <| "no such game-version: " ++ q.version

        Just game ->
            case Dict.get q.hero game.heroes of
                Nothing ->
                    Err <| "no such hero: " ++ q.hero

                Just char ->
                    let
                        ( selected, error ) =
                            case buildToNodes char.graph q.build of
                                Ok selected_ ->
                                    ( selected_, Nothing )

                                Err err ->
                                    -- this error is recoverable: show an empty tree with the error message
                                    ( Set.empty, Just err )
                    in
                    Ok <| ( create game char selected, error )


updateOnChange : GraphModel -> GraphModel -> GraphModel
updateOnChange new old =
    if ( new.game, new.char, new.selected ) == ( old.game, old.char, old.selected ) then
        -- cache everything, when possible. search is updated elsewhere - no need for it to match.
        old

    else
        -- nothing's cacheable. always copy search, it's updated elsewhere.
        { new | search = old.search }
