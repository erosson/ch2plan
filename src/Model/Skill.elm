module Model.Skill
    exposing
        ( energyCost
        , manaCost
        , cooldown
        , duration
        , uptime
        , damage
        , stacks
        , effect
        )

import GameData as G
import GameData.Stats as GS exposing (Stat(..))


skillVal : (GS.Stat -> GS.StatTotal) -> G.Skill -> String -> Maybe Float
skillVal getStat skill name =
    -- fetch a skill-stat, if the stat exists. Skill-stats are specially named stats, for example "BigClicks_damage".
    skill.id ++ "_" ++ name |> GS.getStat |> Maybe.map (getStat >> .val)


skillValOr : (GS.Stat -> GS.StatTotal) -> G.Skill -> Float -> String -> Float
skillValOr getStat skill default =
    -- fetch a skill-stat or a default value.
    skillVal getStat skill >> Maybe.withDefault default


energyCost : (GS.Stat -> GS.StatTotal) -> G.Skill -> Maybe Float
energyCost g s =
    s.energyCost |> Maybe.map (toFloat >> (+) (skillValOr g s 0 "energyCost"))


manaCost : (GS.Stat -> GS.StatTotal) -> G.Skill -> Maybe Float
manaCost g s =
    s.manaCost |> Maybe.map (toFloat >> (*) (skillValOr g s 1 "manaCost"))


cooldown : (GS.Stat -> GS.StatTotal) -> G.Skill -> Maybe Float
cooldown g s =
    s.cooldown |> Maybe.map (toFloat >> (*) (skillValOr g s 1 "cooldown" / 1000 / (g STAT_HASTE).val))


duration : GS.Rules -> (GS.Stat -> GS.StatTotal) -> G.Skill -> Maybe Float
duration rules g s =
    let
        haste =
            -- since 0.07, haste reduces skill duration
            -- https://www.reddit.com/r/ClickerHeroes/comments/9587av/clicker_heroes_2_007_can_now_be_tested/
            if rules.hasteAffectsDuration then
                (g STAT_HASTE).val
            else
                1
    in
        skillVal g s "duration" |> Maybe.map ((*) (1 / 1000 / haste))


uptime : GS.Rules -> (GS.Stat -> GS.StatTotal) -> G.Skill -> Maybe Float
uptime rules g s =
    Maybe.map2 (/)
        (duration rules g s)
        (cooldown g s)
        |> Maybe.map (clamp 0 1)


damage : (GS.Stat -> GS.StatTotal) -> G.Skill -> Maybe Float
damage g s =
    skillVal g s "damage"


stacks : (GS.Stat -> GS.StatTotal) -> G.Skill -> Maybe Float
stacks g s =
    skillVal g s "stacks"


effect : (GS.Stat -> GS.StatTotal) -> G.Skill -> Maybe Float
effect g s =
    skillVal g s "effect"
