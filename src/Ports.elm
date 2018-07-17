port module Ports exposing (..)


port characterData : (Decode.Value -> msg) -> Sub msg
