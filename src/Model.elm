module Model exposing (..)

import Set as Set exposing (Set)
import GameData as G
import Json.Decode as Decode


type Msg
    = SearchInput String
    | SelectInput Int


type alias Model =
    { characterData : G.Character
    , search : Maybe String
    , selected : Set Int
    }


type alias Flags =
    { characterData : Decode.Value
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    case Decode.decodeValue G.characterDecoder flags.characterData of
        Ok char ->
            ( { characterData = char, search = Nothing, selected = Set.empty }, Cmd.none )

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
                    invert id model.selected
            in
                if isValidSelection startNodes (G.graph model.characterData) selected then
                    ( { model | selected = selected }, Cmd.none )
                else
                    ( model, Cmd.none )


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


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
