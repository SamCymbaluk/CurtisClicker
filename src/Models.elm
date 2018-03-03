module Models exposing (..)

import List exposing (map)
import Msgs exposing (Msg)
import Clickers exposing (earnings)
import Upgrades exposing (modifiers)
import Types exposing (Clicker, Upgrade, ClickerData)
import Time exposing (Time)
import Bootstrap.Accordion as Accordion
import Time exposing (Time, second)
import Effects exposing (EffectObject)

type alias Model =
  { loc_counter : Float
  , clickers : List ClickerData
  , lastTick : Time
  , clickEarnings : Float
  , remaining_upgrades : List Upgrade
  , active_upgrades : List Upgrade
  , gui :
    { clickerAccordion : Accordion.State
    , upgradeAccordion : Accordion.State
    , effects : List EffectObject
    , mousePos : { x : Int, y : Int }
    , lastClick : Time
    }
  }

init : ( Model, Cmd Msg )
init =
  ({ loc_counter = 0
   , clickers = Clickers.init
   , lastTick = 0
   , clickEarnings = 1.0
   , remaining_upgrades = Upgrades.list
   , active_upgrades = []
   , gui =
     { clickerAccordion = Accordion.initialState
     , upgradeAccordion = Accordion.initialState
     , effects = []
     , mousePos = { x = 0, y = 0 }
     , lastClick = 0
     }
  }, Cmd.none)

clickerData : Model -> Clicker -> Maybe ClickerData
clickerData model clicker =
  let
    search clickers = case clickers of
      [] ->
        Nothing
      ((c, q, m)::cs) ->
        if c == clicker then
          Just (c, q, m)
        else
          search cs
  in
    search (model.clickers)

clickerEarnings : Model -> Clicker -> Float
clickerEarnings model clicker =
  let
    data = clickerData model clicker
  in
    case data of
      Nothing ->
        0.0
      Just (c, q, m) ->
        (earnings c) * m * (toFloat q)

totalEarnings : Model -> Time -> Float
totalEarnings model interval = List.sum
  (List.map (\(c, q, m) -> (earnings c) * m * (toFloat q) * (interval / Time.second)) model.clickers)

formattedLoc : Float -> List (String, String, Int, String)
formattedLoc l =
  let
    locs = floor l
  in
    [ ("Line of code", "Lines of code",             (locs // 100^0) % 100, "loc")
    , ("Resursive Function", "Resursive Functions", (locs // 100^1) % 100, "function")
    , ("Haskell Program", "Haskell Programs",       (locs // 100^2) % 100, "haskell")
    , ("Research Paper", "Research Papers",         (locs // 100^3) % 100, "research_paper")
    , ("PhD Thesis", "PhD Theses",                  (locs // 100^4) % 100, "thesis")
    , ("Turing Award", "Turing Awards",             (locs // 100^5) % 100, "turing_award")
    ]

reducedLocFormat : Float -> (Float, String)
reducedLocFormat locs =
  let
    values =
      [ (100^5, "Turing Award", "Turing Awards")
      , (100^4, "PhD Thesis", "PhD Theses")
      , (100^3, "Research Paper", "Research Papers")
      , (100^2, "Haskell Program", "Haskell Programs")
      , (100^1, "Resursive Function", "Resursive Functions")
      , (100^0, "Line of code", "Lines of code")
      ]
    listFilter locs (m, _, _) =
      (floor locs) // m > 0
    calcValue maybeHead = case maybeHead of
      Nothing -> --Occurs when locs < 100
        (locs, if isSingular locs then "Line of code" else "Lines of code")
      Just (m, t, ts) ->
        (locs / (toFloat m), if isSingular (locs / (toFloat m)) then t else ts)
    isSingular float = (abs (float - 1)) < 0.001
  in
    List.filter (listFilter locs) values
     |> List.head
     |> calcValue

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
      applyModifiers { model | clickers = map (updateClicker c multiplier) model.clickers } (cs, multiplier)
