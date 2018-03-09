module Types exposing (..)

import Time exposing (Time)

type Upgrade =
  Ubuntu
  | Emacs
  | Coffee
  | Deadlines
  | Tenure
  | UnethicalStudies

upgradeList : List Upgrade
upgradeList = [
  Ubuntu
  , Emacs
  , Coffee
  , Deadlines
  , Tenure
  , UnethicalStudies
  ]

type Clicker =
  Macro
  | BashScript
  | SOScraper
  | UndergradStudent
  | GradStudent
  | Professor
  | Startup
  | ResearchTeam
  | AGI

clickerList : List Clicker
clickerList = [
  Macro
  , BashScript
  , SOScraper
  , UndergradStudent
  , GradStudent
  , Professor
  , Startup
  , ResearchTeam
  , AGI
  ]

type alias ClickerData = (Clicker, Int, Float)

type ShopItem =
  ClickerItem Clicker
  | UpgradeItem Upgrade

type alias SerializedModel =
  { loc_counter : Float
  , clickers : List (Int, Int, Float)
  , lastTick : Time
  , clickEarnings : Float
  , remaining_upgrades : List Int
  , active_upgrades : List Int
  }
