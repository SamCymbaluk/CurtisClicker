module Models exposing (..)

import List exposing (map)
import Msgs exposing (Msg)
import Clickers exposing (earnings)
import Types exposing (Clicker, Upgrade, ClickerData)
import Time exposing (Time)
import Bootstrap.Accordion as Accordion
import Bootstrap.Modal as Modal
import Time exposing (Time, second)
import Effects exposing (EffectObject)

type alias Model =
  { loc_counter : Float
  , clickers : List ClickerData
  , lastTick : Time
  , clickEarnings : Float
  , remaining_upgrades : List Upgrade
  , active_upgrades : List Upgrade
  , modalOpened : Bool
  , gui :
    { clickerAccordion : Accordion.State
    , upgradeAccordion : Accordion.State
    , introModalVis : Modal.Visibility
    , effects : List EffectObject
    , mousePos : { x : Int, y : Int }
    , lastClick : Time
    , bgCodePos : Float
    , bgCodeIndex : Int
    }
  }

init : ( Model, Cmd Msg )
init =
  ({ loc_counter = 0
   , clickers = Clickers.init
   , lastTick = 0
   , clickEarnings = 1.0
   , remaining_upgrades = Types.upgradeList
   , active_upgrades = []
   , modalOpened = False
   , gui =
     { clickerAccordion = Accordion.initialState
     , upgradeAccordion = Accordion.initialState
     , introModalVis = Modal.hidden
     , effects = []
     , mousePos = { x = 0, y = 0 }
     , lastClick = 0
     , bgCodePos = 0.0
     , bgCodeIndex = 0
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
  -- Doesn't use clickerEarnings, as that would do a number of unnecessary searches of model.clickers
  (List.map (\(c, q, m) -> (earnings c) * m * (toFloat q) * (interval / Time.second)) model.clickers)

{-| Formats a raw line of code float as an combination of integer quantities larger denominations
Returned data includes denomination names and image paths
-}
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
    , ("Turing Award", "Turing Awards",             (locs // 100^5)      , "turing_award")
    ]

{-| Formats a raw line of code float as the largest denomination such that
there is at least one of that denomination -}
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
    List.filter (listFilter locs) values --Drop any < 1 denomination representations
     |> List.head
     |> calcValue
