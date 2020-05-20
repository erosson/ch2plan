module View.Changelog exposing (view)

import Html as H exposing (..)
import Html.Attributes as A exposing (..)
import Html.Events as E exposing (..)
import Markdown


view : String -> Html msg
view =
    Markdown.toHtml [ class "changelog" ]
