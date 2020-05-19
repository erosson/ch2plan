module Lazy exposing (Lazy, evaluate, force, lazy, toMaybe)

{-| I miss Elm 0.18's Lazy module. This is a cheap imitation.

This one's pure, but much less convenient than the original: no side effects.
You must evaluate and store Lazy results yourself.

-}


type Lazy a
    = Lazy (() -> a)
    | Evaluated a


lazy : (() -> a) -> Lazy a
lazy =
    Lazy


{-| Evaluate and store a lazy value. After evaluation, it will never be re-run.
-}
evaluate : Lazy a -> Lazy a
evaluate lazyVal =
    case lazyVal of
        Lazy thunk ->
            Evaluated (thunk ())

        Evaluated _ ->
            lazyVal


{-| Return a value only if it's already been evaluated.
-}
toMaybe : Lazy a -> Maybe a
toMaybe lazyVal =
    case lazyVal of
        Evaluated val ->
            Just val

        Lazy _ ->
            Nothing


{-| Evaluate a lazy value if needed, and return it.

Unlike the original Elm 0.18 Lazy module, this does not cache the result:
multiple uses of force will evalulate the value multiple times. To avoid this,
store the result of Lazy.evaluate.

-}
force : Lazy a -> a
force lazyVal =
    case lazyVal of
        Evaluated val ->
            val

        Lazy thunk ->
            thunk ()
