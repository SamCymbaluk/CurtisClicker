module Clickers exposing (..)

import List exposing (map)
import Types exposing (..)

{-| Creates the initial data for clickers
to be used in the Model -}
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
  SOScraper -> 7
  Startup -> 8

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
  7 -> Just SOScraper
  8 -> Just Startup
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
          SOScraper ->
            "Stackoverflow Scraper"
          UndergradStudent ->
            "Undergrad Student"
          GradStudent ->
            "Grad Student"
          Professor ->
            "Professor"
          Startup ->
            "Tech Startup"
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
      "Keep everything under CTRL"
    BashScript ->
      "'Automating' comes from the roots\n"
      ++ "'auto-' meaning 'self-', and\n"
      ++ "'mating', meaning 'screwing'. ~xkcd"
    SOScraper ->
      "The creation of Stackoverflow is\n"
      ++ "the original bootstrap paradox"
    UndergradStudent ->
      "Code quality not guaranteed"
    GradStudent ->
      "Knows enough to have heard of\n"
      ++ "unsafePerformIO, but not enough\n"
      ++ "to know not to use it"
    Professor ->
      "Have the professors working for YOU"
    Startup ->
      "Something something Deep Learning Blockchain"
    ResearchTeam ->
      "What one programmer can do in one week\n"
      ++ "five programmers can do in five weeks"
    AGI ->
      "The Singularity is upon us!"

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
      SOScraper ->
        defaultInc 3000 amt
      UndergradStudent ->
        defaultInc 10000 amt
      GradStudent ->
        defaultInc 70000 amt
      Professor ->
        defaultInc 700000 amt
      Startup ->
        defaultInc 10000000 amt
      ResearchTeam ->
        defaultInc 30000000 amt
      AGI ->
        100^5

{-| Returns the base loc earnings per second for a Clicker
-}
earnings : Clicker -> Float
earnings clicker = case clicker of
  Macro ->
    0.5
  BashScript ->
    5.0
  SOScraper ->
    20.0
  UndergradStudent ->
    50.0
  GradStudent ->
    250.0
  Professor ->
    1000.0
  Startup ->
    8000.0
  ResearchTeam ->
    20000.0
  AGI ->
    50000000.0
