module Upgrades exposing (..)

import Types exposing (..)
import Models exposing (..)

-- Serialize Upgrades
toInt : Upgrade -> Int
toInt u = case u of
  Ubuntu -> 0
  Emacs -> 1
  Coffee -> 2

-- Deserialize upgrades
fromInt : Int -> Maybe Upgrade
fromInt i = case i of
  0 -> Just Ubuntu
  1 -> Just Emacs
  2 -> Just Coffee
  _ -> Nothing

modifiers : Upgrade -> (List Clicker, Float)
modifiers upgrade = case upgrade of
  Ubuntu ->
    (clickerList, 0.1)
  Emacs ->
    (clickerList, 0.5)
  Coffee ->
    ([UndergradStudent, GradStudent], 0.2)

unlocked : Model -> Upgrade -> Bool
unlocked model upgrade = True

cost : Upgrade -> Int
cost upgrade = case upgrade of
  Ubuntu ->
    100
  Emacs ->
    100
  Coffee ->
    1000

applyUpgrade : Model -> Upgrade -> Model
applyUpgrade model upgrade =
  applyModifiers model (modifiers upgrade)

applyModifiers : Model -> (List Clicker, Float) -> Model
applyModifiers model modifiers = case modifiers of
  ([], _) ->
    model
  ((c::cs), multiplier) ->
    let
      -- Function for map to apply to selectively
      -- update clicker tuples
      updateClicker clicker multiplier entry =
        let
          (c, q, m) = entry
        in
          if clicker == c then
            (c, q, m + multiplier)
          else
            entry
    in
      applyModifiers { model | clickers = List.map (updateClicker c multiplier) model.clickers } (cs, multiplier)
