module Effects exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style, src, width, height)
import Msgs exposing (Msg)
import Time exposing (Time, second)
import Maybe.Extra
import Random

type alias EffectObject =
  { x : Float
  , y : Float
  , img : String
  , vel : (Float, Float)
  , acc : (Float, Float)
  , ticksToLive : Int
  , height : Int
  , width : Int
  }

{-| Applies time-based effects to a list of EffectObjects
List size will decrease as effects expire-}
tickEffects : List EffectObject -> Time -> List EffectObject
tickEffects effects interval =
  Maybe.Extra.values (List.map (tickEffect interval) effects)

tickEffect : Time -> EffectObject -> Maybe EffectObject
tickEffect interval effect =
  if shouldDie effect then
    Nothing -- Remove the effectObject
  else
    let
      (vel_x, vel_y) = effect.vel
      (acc_x, acc_y) = effect.acc
    in
      Just { effect | x = effect.x + vel_x * interval -- Movement x
           , y = effect.y + vel_y * interval          -- Movement y
           , vel = (vel_x + acc_x, vel_y + acc_y)     -- Acceleration
           , ticksToLive = effect.ticksToLive - 1 }

shouldDie : EffectObject -> Bool
shouldDie effect =
  effect.x < 0.0 || effect.x > 4000.0
  || effect.y < 0.0 || effect.y > 4000.0
  || effect.ticksToLive == 0

drawEffects : List EffectObject -> List (Html Msg)
drawEffects effects = List.map drawEffect effects

{-| Creates a Html element from an EffectObject -}
drawEffect : EffectObject -> Html Msg
drawEffect effect =
  img
    [ src effect.img
    , width effect.width
    , height effect.height
    , style
      [ ("position", "fixed")
      , ("top", toString ((round effect.y) - (effect.height // 2)) ++ "px")
      , ("left", toString ((round effect.x) - (effect.width // 2)) ++ "px")
      , ("z-index", "0")
      , ("pointer-events", "none") --Prevents the effect from blocking clicks
      ]
    ]
    []

{-| Generator for velocity pairs -}
generateVels : Int -> Random.Generator (List (Float, Float))
generateVels amt =
  Random.list amt
    <| Random.pair (Random.float 0 1) (Random.float 0 1)
