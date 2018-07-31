module View.Changelog exposing (view)

import Html as H
import Html.Attributes as A
import Html.Events as E
import Model as M
import Route
import Markdown


view : String -> H.Html M.Msg
view =
    Markdown.toHtml [ A.class "changelog" ]
