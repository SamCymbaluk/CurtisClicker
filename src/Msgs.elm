module Msgs exposing (..)

import Time exposing (Time, second)
import Types exposing (..)

import Bootstrap.Accordion as Accordion

type Msg =
  None
  | Tick Time Time
  | SaveInterval Time Time
  | ApplyModel (Maybe SerializedModel)
  | Click
  | Purchase ShopItem
  | ClickerAccordion Accordion.State
  | UpgradeAccordion Accordion.State
