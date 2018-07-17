module Model exposing (..)

import GameData
import Json.Decode as Decode


type Msg
    = NoOp


type alias Model =
    { characterData : GameData.Character }


type alias Flags =
    { characterData : Decode.Value
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    case Decode.decodeValue GameData.characterDecoder flags.characterData of
        Ok char ->
            ( { characterData = char }, Cmd.none )

        Err err ->
            Debug.crash err


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
