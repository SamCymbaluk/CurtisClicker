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

modifiers : Upgrade -> (List Clicker, Float, Float)
modifiers upgrade = case upgrade of
  Ubuntu ->
    (clickerList, 0.1, 2.0)
  Emacs ->
    (clickerList, 0.5, 2.0)
  Coffee ->
    ([UndergradStudent, GradStudent, Professor], 0.25, 1.0)

unlocked : Model -> Upgrade -> Bool
unlocked model upgrade = True{-case upgrade of
  Ubuntu ->
    True
  Emacs ->
    True
  Coffee ->
    (clickerAmount model UndergradStudent > 0) || (clickerAmount model GradStudent > 0)-}

name : Upgrade -> String
name upgrade = case upgrade of
  Ubuntu ->
    "Install Ubuntu"
  Emacs ->
    "Switch to Emacs"
  Coffee ->
    "Coffee Machine"

cost : Upgrade -> Int
cost upgrade = case upgrade of
  Ubuntu ->
    500
  Emacs ->
    500
  Coffee ->
    2000

description : Upgrade -> String
description upgrade = case upgrade of
  Ubuntu ->
    "The first step towards the dark side."
  Emacs ->
    "Emacs"
  Coffee ->
    "Coffee"

clickerAmount : Model -> Clicker -> Int
clickerAmount model clicker =
  let
    fold (c, q, m) b = if c == clicker then q + b else b
  in
    List.foldr fold 0 model.clickers

applyUpgrade : Model -> Upgrade -> Model
applyUpgrade model upgrade =
  applyModifiers model (modifiers upgrade)

applyModifiers : Model -> (List Clicker, Float, Float) -> Model
applyModifiers model modifiers = case modifiers of
  ([], _, _) ->
    model
  ((c::cs), multiplier, clickMultiplier) ->
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
      applyModifiers { model | clickers = List.map (updateClicker c multiplier) model.clickers
                             , clickEarnings = model.clickEarnings * clickMultiplier } (cs, multiplier, 1.0) --Pass clickMultipler of one since we only apply it once
