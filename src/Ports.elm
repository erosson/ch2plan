port module Ports exposing (SaveFileData, saveFileContentRead, saveFileSelected)


type alias SaveFileData =
    { hero : String
    , build : List String
    , error : Maybe String
    }


port saveFileSelected : String -> Cmd msg


port saveFileContentRead : (SaveFileData -> msg) -> Sub msg
