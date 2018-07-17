module Main exposing (..)

import Dict as Dict exposing (Dict)
import Json.Decode as Decode
import Html as H
import GameData


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


view : Model -> H.Html Msg
view model =
    H.div []
        [ H.text <| toString model ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program Flags Model Msg
main =
    H.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
