module View.FormatUtil exposing (float, int, pct, pct0, pct0N, pctN, sec)

import Round


pct : Float -> String
pct =
    pctN 0


pctN : Int -> Float -> String
pctN n f =
    (f * 100 |> Round.round n) ++ "%"


float : Int -> Float -> String
float sigfigs f =
    let
        exp =
            10 ^ toFloat sigfigs
    in
    (f * exp |> floor |> toFloat) / exp |> String.fromFloat


sec : Int -> Float -> String
sec sigfigs f =
    float sigfigs f ++ "s"


pct0 f =
    pct <| f - 1


pct0N n f =
    pctN n <| f - 1


int =
    String.fromInt << floor
