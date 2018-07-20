module ViewChangelog exposing (view)

import Html as H
import Html.Attributes as A
import Html.Events as E
import Model as M
import Route
import Markdown


view : Maybe String -> H.Html M.Msg
view changelog =
    case changelog of
        Nothing ->
            H.div [] [ H.text "Failed to load changelog. Try refreshing the page?" ]

        Just markdown ->
            Markdown.toHtml [ A.class "changelog" ] markdown
