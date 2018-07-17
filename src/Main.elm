module Main exposing (..)

import Html as H
import Model as M
import View as V


main : Program M.Flags M.Model M.Msg
main =
    H.programWithFlags
        { init = M.init
        , view = V.view
        , update = M.update
        , subscriptions = M.subscriptions
        }
