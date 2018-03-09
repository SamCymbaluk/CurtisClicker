module Upgrades exposing (..)

import Types exposing (..)
import Models exposing (..)
import Time exposing (Time, second)

-- Serialize Upgrades
toInt : Upgrade -> Int
toInt u = case u of
  Ubuntu -> 0
  Emacs -> 1
  Coffee -> 2
  Deadlines -> 3
  Tenure -> 4
  UnethicalStudies -> 5

-- Deserialize upgrades
fromInt : Int -> Maybe Upgrade
fromInt i = case i of
  0 -> Just Ubuntu
  1 -> Just Emacs
  2 -> Just Coffee
  3 -> Just Deadlines
  4 -> Just Tenure
  5 -> Just UnethicalStudies
  _ -> Nothing

modifiers : Upgrade -> (List Clicker, Float, Float)
modifiers upgrade = case upgrade of
  Ubuntu ->
    (clickerList, 0.1, 2.0)
  Emacs ->
    (clickerList, 0.5, 2.0)
  Coffee ->
    ([UndergradStudent, GradStudent, Professor], 0.25, 1.0)
  Deadlines ->
    ([UndergradStudent, GradStudent], 0.25, 25.0)
  Tenure ->
    ([Professor], 1.0, 1.0)
  UnethicalStudies ->
    ([ResearchTeam], 1.0, 1.0)

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
  Deadlines ->
    "Fast-approaching Deadlines"
  Tenure ->
    "Open Tenure Position"
  UnethicalStudies ->
    "Unethical research"


cost : Upgrade -> Int
cost upgrade = case upgrade of
  Ubuntu ->
    500
  Emacs ->
    500
  Coffee ->
    5000
  Deadlines ->
    75000
  Tenure ->
    1800000
  UnethicalStudies ->
    100000000

description : Upgrade -> String
description upgrade = case upgrade of
  Ubuntu ->
    "The first step towards the dark side."
  Emacs ->
    "Take the time to learn Emacs and you will\n"
    ++ "reap the rewards for the rest of your career\n"
    ++ "...or so I'm told"
  Coffee ->
    "A programmer is just an organism that\n"
    ++ "converts coffee into code"
  Deadlines ->
    "Due tomorrow? Do tomorrow."
  Tenure ->
    ""
  UnethicalStudies ->
    "AI Safety? What's that?"

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
