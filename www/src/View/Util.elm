module View.Util exposing (nodeBackgroundImage, nodeIconUrl, nodeQualityClass)

import GameData exposing (GameData)
import Set exposing (Set)


nodeIconUrl : GameData.NodeType -> String
nodeIconUrl node =
    let
        notfound =
            "./ch2data/404.png"
    in
    case node.icon of
        Nothing ->
            notfound

        Just icon ->
            if Set.member icon missingIcons then
                notfound

            else
                "./ch2data/img/" ++ icon ++ ".png"


missingIcons : Set String
missingIcons =
    -- We can't easily export new skill tree icons anymore: for an explanation,
    -- see `./scripts/export/icons`. New icons are simply missing.
    -- As a crude workaround, list known new-icons and replace them with a
    -- better not-found image.
    -- (I wish I could write an `alt` tag with html instead of text instead)
    Set.fromList
        [ ""
        , "autoAttack"
        , "playIcon"
        , "pauseIcon"
        , "MgtEIcon"
        , "EgtMIcon"
        , "firstMonsterIcon"
        , "NMgt90Icon"
        , "NMlt90Icon"
        ]


nodeBackgroundImage : GameData.NodeType -> { isHighlighted : Bool, isSelected : Bool, isNeighbor : Bool } -> String
nodeBackgroundImage node { isHighlighted, isSelected, isNeighbor } =
    let
        quality =
            case node.quality of
                GameData.Keystone ->
                    "deluxeNode"

                GameData.Notable ->
                    "specialNode"

                GameData.Plain ->
                    "generalNode"

        suffix =
            if isHighlighted then
                "Highlight"

            else if isSelected then
                -- SelectedVis has a green border, while Selected is just like in-game.
                -- Small nodes aren't visible enough when selected - too small,
                -- not enough color; in-game they're animated so it's more visible -
                -- so give them the border. Other nodes are visible enough without
                -- the extra border - much larger, with more color - so leave them alone.
                if node.quality == GameData.Plain then
                    "SelectedVis"

                else
                    "Selected"

            else if isNeighbor then
                "Next"

            else
                ""
    in
    "./ch2data/node-img/" ++ quality ++ suffix ++ ".png?3"


nodeQualityClass : GameData.NodeQuality -> String
nodeQualityClass =
    GameData.qualityToString >> (++) "node-"
