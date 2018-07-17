module Model exposing (..)

import GameData
import Json.Decode as Decode


type Msg
    = SearchInput String


type alias Model =
    { characterData : GameData.Character
    , search : Maybe String
    }


type alias Flags =
    { characterData : Decode.Value
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    case Decode.decodeValue GameData.characterDecoder flags.characterData of
        Ok char ->
            ( { characterData = char, search = Nothing }, Cmd.none )

        Err err ->
            Debug.crash err


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SearchInput str ->
            case str of
                "" ->
                    ( { model | search = Nothing }, Cmd.none )

                _ ->
                    ( { model | search = Just str }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
