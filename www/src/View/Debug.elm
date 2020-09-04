module View.Debug exposing (view)

import GameData exposing (GameData)
import Html as H exposing (..)
import Html.Attributes as A exposing (..)
import Html.Events as E exposing (..)
import Model exposing (Model, Msg)


view : Model -> GameData -> Html Msg
view model gameData =
    div [] [ text "debug" ]
