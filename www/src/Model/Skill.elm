module Model.Skill exposing
    ( cooldown
    , damage
    , duration
    , effect
    , energyCost
    , manaCost
    , stacks
    , uptime
    )

import GameData exposing (GameData)
import GameData.Stats as Stats exposing (Stat(..), StatTotal)


skillVal : (Stats.Stat -> Result String StatTotal) -> GameData.Skill -> String -> Result String Float
skillVal getStat skill name =
    -- fetch a skill-stat, if the stat exists. Skill-stats are specially named stats, for example "BigClicks_damage".
    let
        sname =
            skill.id ++ "_" ++ name
    in
    Stats.getStat sname
        |> Result.fromMaybe ("no such skill-stat: " ++ sname)
        |> Result.andThen getStat
        |> Result.map .val


skillValOr : (Stat -> Result String StatTotal) -> GameData.Skill -> Float -> String -> Float
skillValOr getStat skill default =
    -- fetch a skill-stat or a default value.
    skillVal getStat skill >> Result.withDefault default


energyCost : (Stat -> Result String StatTotal) -> GameData.Skill -> Result String Float
energyCost g s =
    s.energyCost |> Result.fromMaybe "no energycost" |> Result.map (toFloat >> (+) (skillValOr g s 0 "energyCost"))


manaCost : (Stat -> Result String StatTotal) -> GameData.Skill -> Result String Float
manaCost g s =
    s.manaCost |> Result.fromMaybe "no manacost" |> Result.map (toFloat >> (*) (skillValOr g s 1 "manaCost"))


cooldown : (Stat -> Result String StatTotal) -> GameData.Skill -> Result String Float
cooldown g s =
    let
        haste =
            case g STAT_HASTE of
                Err _ ->
                    1

                Ok h ->
                    h.val
    in
    s.cooldown |> Result.fromMaybe "no cooldown" |> Result.map (toFloat >> (*) (skillValOr g s 1 "cooldown" / 1000 / haste))


duration : Stats.Rules -> (Stat -> Result String StatTotal) -> GameData.Skill -> Result String Float
duration rules g s =
    let
        haste =
            -- since 0.07, haste reduces skill duration
            -- https://www.reddit.com/r/ClickerHeroes/comments/9587av/clicker_heroes_2_007_can_now_be_tested/
            if rules.hasteAffectsDuration then
                case g STAT_HASTE of
                    Ok h ->
                        h.val

                    Err _ ->
                        1

            else
                1
    in
    skillVal g s "duration" |> Result.map ((*) (1 / 1000 / haste))


uptime : Stats.Rules -> (Stat -> Result String StatTotal) -> GameData.Skill -> Result String Float
uptime rules g s =
    Result.map2 (/)
        (duration rules g s)
        (cooldown g s)
        |> Result.map (clamp 0 1)


damage : (Stat -> Result String StatTotal) -> GameData.Skill -> Result String Float
damage g s =
    skillVal g s "damage"


stacks : (Stat -> Result String StatTotal) -> GameData.Skill -> Result String Float
stacks g s =
    skillVal g s "stacks"


effect : (Stat -> Result String StatTotal) -> GameData.Skill -> Result String Float
effect g s =
    skillVal g s "effect"
