port module Ports exposing (saveFileContentRead, saveFileSelected)

import Json.Decode as D


port saveFileSelected : String -> Cmd msg


port saveFileContentRead : (D.Value -> msg) -> Sub msg
