module Clickers exposing (..)

import List exposing (map)
import Types exposing (..)

init : List ClickerData
init = map (\c -> (c, 0, 1.0)) clickerList

clicker : ClickerData -> Clicker
clicker (c, _, _) = c

quantity : ClickerData -> Int
quantity (_, q, _) = q

multiplier : ClickerData -> Float
multiplier (_, _, m) = m

-- Serialize clickers
toInt : Clicker -> Int
toInt c = case c of
  Macro -> 0
  BashScript -> 1
  UndergradStudent -> 2
  GradStudent -> 3
  Professor -> 4
  ResearchTeam -> 5
  AGI -> 6

-- Deserialize clickers
fromInt : Int -> Maybe Clicker
fromInt i = case i of
  0 -> Just Macro
  1 -> Just BashScript
  2 -> Just UndergradStudent
  3 -> Just GradStudent
  4 -> Just Professor
  5 -> Just ResearchTeam
  6 -> Just AGI
  _ -> Nothing

{-| Returns the friendly name of a Clicker.
Either in the plural (True) or singular (False) form
depending on the passed Bool
-}
name : Clicker -> Bool -> String
name clicker plural =
  let
    s = case clicker of
          Macro ->
            "Macro"
          BashScript ->
            "Bash Script"
          UndergradStudent ->
            "Undergrad Student"
          GradStudent ->
            "Grad Student"
          Professor ->
            "Professor"
          ResearchTeam ->
            "Research Team"
          AGI ->
            "Artificial General Intelligence"
  in
    s ++ if plural then "s" else ""

{-| Returns the description/flavour text of a clicker
-}
description : Clicker -> String
description clicker =
  case clicker of
    Macro ->
      "Macro"
    BashScript ->
      "Bash Script"
    UndergradStudent ->
      "Undergrad Student"
    GradStudent ->
      "Grad Student"
    Professor ->
      "Professor"
    ResearchTeam ->
      "Research Team"
    AGI ->
      "Artificial General Intelligence"

{-| Returns the purchase cost of a Clicker, given
that some quantity has already been purchased
-}
cost : Clicker -> Int -> Int
cost clicker amt =
  let
    defaultInc = \c n -> c + (c*n)//20
  in
    case clicker of
      Macro ->
        defaultInc 50 amt
      BashScript ->
        defaultInc 500 amt
      UndergradStudent ->
        defaultInc 3000 amt
      GradStudent ->
        defaultInc 20000 amt
      Professor ->
        defaultInc 200000 amt
      ResearchTeam ->
        defaultInc 5000000 amt
      AGI ->
        defaultInc (100^5) amt

{-| Returns the base loc earnings per second for a Clicker
-}
earnings : Clicker -> Float
earnings clicker = case clicker of
  Macro ->
    0.5
  BashScript ->
    5.0
  UndergradStudent ->
    20.0
  GradStudent ->
    50.0
  Professor ->
    1000.0
  ResearchTeam ->
    25000.0
  AGI ->
    50000000.0
