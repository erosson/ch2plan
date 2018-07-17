module Main exposing (..)

import Navigation
import Model as M
import View as V


main : Program M.Flags M.Model M.Msg
main =
    Navigation.programWithFlags M.NavLocation
        { init = M.init
        , view = V.view
        , update = M.update
        , subscriptions = M.subscriptions
        }
