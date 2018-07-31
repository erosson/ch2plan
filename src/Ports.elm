port module Ports exposing (..)


type alias SaveFileData =
    { hero : String
    , build : String
    }


port saveFileSelected : String -> Cmd msg


port saveFileContentRead : (SaveFileData -> msg) -> Sub msg
