module Main exposing (main)

import Browser
import Model exposing (Flags, Model, Msg)
import View


main : Program Flags Model Msg
main =
    Browser.application
        { init = Model.init
        , view = View.view
        , update = Model.update
        , subscriptions = Model.subscriptions

        -- clicking a link
        , onUrlRequest = Model.NavRequest

        -- other url changes, like altering the address bar
        , onUrlChange = Model.NavLocation
        }
