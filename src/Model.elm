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
            if isSelectable id model then
                ( { model | selected = invert id model.selected }, Cmd.none )
            else
                ( model, Cmd.none )


isSelectable : G.NodeId -> Model -> Bool
isSelectable id model =
    -- TODO: restrict nodes by edges
    True


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
