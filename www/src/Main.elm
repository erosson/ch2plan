module Main exposing (main)

import Browser
import Model as M
import View as V


main =
    Browser.application
        { init = M.init
        , view = V.view
        , update = M.update
        , subscriptions = M.subscriptions

        -- clicking a link
        , onUrlRequest = M.NavRequest

        -- other url changes, like altering the address bar
        , onUrlChange = M.NavLocation
        }
