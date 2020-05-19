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

import GameData as G
import GameData.Stats as GS exposing (Stat(..))


skillVal : (GS.Stat -> Result String GS.StatTotal) -> G.Skill -> String -> Result String Float
skillVal getStat skill name =
    -- fetch a skill-stat, if the stat exists. Skill-stats are specially named stats, for example "BigClicks_damage".
    let
        sname =
            skill.id ++ "_" ++ name
    in
    GS.getStat sname
        |> Result.fromMaybe ("no such skill-stat: " ++ sname)
        |> Result.andThen getStat
        |> Result.map .val


skillValOr : (GS.Stat -> Result String GS.StatTotal) -> G.Skill -> Float -> String -> Float
skillValOr getStat skill default =
    -- fetch a skill-stat or a default value.
    skillVal getStat skill >> Result.withDefault default


energyCost : (GS.Stat -> Result String GS.StatTotal) -> G.Skill -> Result String Float
energyCost g s =
    s.energyCost |> Result.fromMaybe "no energycost" |> Result.map (toFloat >> (+) (skillValOr g s 0 "energyCost"))


manaCost : (GS.Stat -> Result String GS.StatTotal) -> G.Skill -> Result String Float
manaCost g s =
    s.manaCost |> Result.fromMaybe "no manacost" |> Result.map (toFloat >> (*) (skillValOr g s 1 "manaCost"))


cooldown : (GS.Stat -> Result String GS.StatTotal) -> G.Skill -> Result String Float
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


duration : GS.Rules -> (GS.Stat -> Result String GS.StatTotal) -> G.Skill -> Result String Float
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


uptime : GS.Rules -> (GS.Stat -> Result String GS.StatTotal) -> G.Skill -> Result String Float
uptime rules g s =
    Result.map2 (/)
        (duration rules g s)
        (cooldown g s)
        |> Result.map (clamp 0 1)


damage : (GS.Stat -> Result String GS.StatTotal) -> G.Skill -> Result String Float
damage g s =
    skillVal g s "damage"


stacks : (GS.Stat -> Result String GS.StatTotal) -> G.Skill -> Result String Float
stacks g s =
    skillVal g s "stacks"


effect : (GS.Stat -> Result String GS.StatTotal) -> G.Skill -> Result String Float
effect g s =
    skillVal g s "effect"
