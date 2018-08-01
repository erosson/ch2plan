port module Ports exposing (..)


type alias SaveFileData =
    { hero : String
    , build : List String
    , error : Maybe String
    }


port saveFileSelected : String -> Cmd msg


port saveFileContentRead : (SaveFileData -> msg) -> Sub msg


type alias SearchRegex =
    { string : Maybe String, error : Maybe String }


port searchUpdated : () -> Cmd msg


{-| parse search strings in js, because <https://github.com/erosson/ch2plan/issues/44>
-}
port searchRegex : (SearchRegex -> msg) -> Sub msg
