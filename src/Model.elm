module Model exposing (..)

import Char
import Set as Set exposing (Set)
import Dict as Dict exposing (Dict)
import Json.Decode as Decode
import Navigation
import Maybe.Extra
import List.Extra
import GameData as G
import Route as Route exposing (Route)


type Msg
    = SearchInput String
    | SelectInput Int -- TODO should really remove this one in favor of links
    | NavLocation Navigation.Location
    | NavRoute Route


type alias Model =
    { characterData : G.Character
    , route : Route
    , search : Maybe String
    }


type alias Flags =
    { characterData : Decode.Value
    }


init : Flags -> Navigation.Location -> ( Model, Cmd Msg )
init flags loc =
    case Decode.decodeValue G.characterDecoder flags.characterData of
        Ok char ->
            ( { characterData = char
              , route = Route.parse loc
              , search = Nothing
              }
            , Cmd.none
            )

        Err err ->
            Debug.crash err


invert : comparable -> Set comparable -> Set comparable
invert id set =
    if Set.member id set then
        Set.remove id set
    else
        Set.insert id set


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SearchInput str ->
            case str of
                "" ->
                    ( { model | search = Nothing }, Cmd.none )

                _ ->
                    ( { model | search = Just str }, Cmd.none )

        SelectInput id ->
            let
                selected =
                    invert id <| selectedNodes model

                g =
                    G.graph model.characterData

                _ =
                    ( nodesToBuild g selected, buildToNodes startNodes g (nodesToBuild g selected) ) |> Debug.log "build"

                route =
                    Route.Home { build = nodesToBuild g selected }
            in
                if isValidSelection startNodes g selected then
                    ( model, Navigation.modifyUrl <| Route.stringify route )
                else
                    ( model, Cmd.none )

        NavLocation loc ->
            ( { model | route = Route.parse loc }, Cmd.none )

        NavRoute route ->
            ( { model | route = route }, Cmd.none )


startNodes : Set G.NodeId
startNodes =
    -- TODO is this defined in the actual data?
    Set.singleton 1


reachableSelectedNodes : Set G.NodeId -> G.Graph -> Set G.NodeId -> Set G.NodeId
reachableSelectedNodes startNodes graph selected =
    let
        loop : G.NodeId -> { reachable : Set G.NodeId, tried : Set G.NodeId } -> { reachable : Set G.NodeId, tried : Set G.NodeId }
        loop id res =
            if Set.member id res.tried then
                res
            else
                let
                    nextIds =
                        G.neighbors id graph |> Set.intersect selected
                in
                    Set.foldr loop { tried = Set.insert id res.tried, reachable = Set.union res.reachable nextIds } nextIds

        startReachable =
            Set.intersect selected startNodes
    in
        Set.foldr loop { tried = Set.empty, reachable = startReachable } startReachable
            |> .reachable


isValidSelection : Set G.NodeId -> G.Graph -> Set G.NodeId -> Bool
isValidSelection startNodes graph selected =
    reachableSelectedNodes startNodes graph selected == selected


selectableNodes : Set G.NodeId -> G.Graph -> Set G.NodeId -> Set G.NodeId
selectableNodes startNodes graph selected =
    Set.foldr (\id -> \res -> G.neighbors id graph |> Set.union res) startNodes selected
        |> \res -> Set.diff res selected


nodesToBuild : G.Graph -> Set G.NodeId -> Maybe String
nodesToBuild graph =
    Set.toList
        >> List.map nodeToString
        >> String.join "&"
        >> (\s ->
                if s == "" then
                    Nothing
                else
                    Just s
           )


nodeToString : G.NodeId -> String
nodeToString =
    -- Char.fromCode >> String.fromChar
    toString


buildToNodes : Set G.NodeId -> G.Graph -> Maybe String -> Set G.NodeId
buildToNodes startNodes graph =
    Maybe.withDefault ""
        >> String.split "&"
        >> List.map (String.toInt >> Result.toMaybe)
        >> \ids0 ->
            let
                ids =
                    ids0 |> Maybe.Extra.values |> Set.fromList
            in
                if List.length ids0 == Set.size ids && isValidSelection startNodes graph ids then
                    ids
                else
                    Set.empty


selectedNodes : Model -> Set G.NodeId
selectedNodes model =
    case model.route of
        Route.Home { build } ->
            buildToNodes startNodes (G.graph model.characterData) build


summary : Model -> List ( Int, G.NodeType )
summary model =
    let
        selected =
            selectedNodes model
    in
        G.graph model.characterData
            |> .nodes
            |> Dict.filter (\id nodeType -> Set.member id selected)
            |> Dict.values
            |> List.map .val
            |> List.sortBy .name
            |> List.Extra.group
            |> List.map (\g -> List.head g |> Maybe.map ((,) (List.length g)))
            |> Maybe.Extra.values
            |> List.sortBy
                (\( count, nodeType ) ->
                    -1
                        * (count
                            -- I really can't sort on a tuple, Elm? Sigh.
                            + case nodeType.quality of
                                G.Keystone ->
                                    1000000

                                G.Notable ->
                                    1000

                                G.Plain ->
                                    0
                          )
                )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
