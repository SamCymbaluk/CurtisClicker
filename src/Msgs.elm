module Msgs exposing (..)

import Time exposing (Time, second)
import Types exposing (..)
import Mouse

import Bootstrap.Accordion as Accordion

type Msg =
  None
  | Tick Time Time
  | AnimTick Float
  | SaveInterval Time Time
  | MousePos (Mouse.Position)
  | ApplyModel (Maybe SerializedModel)
  | Click
  | ClickEffects (List (Float, Float))
  | Purchase ShopItem
  | ClickerAccordion Accordion.State
  | UpgradeAccordion Accordion.State
  | CloseIntroModal
  | ShowIntroModal
