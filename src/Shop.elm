module Shop exposing (..)

import Models exposing (Model)
import Clickers exposing (clicker, quantity, multiplier)
import Upgrades
import Types exposing (..)

cost : Model -> ShopItem -> Int
cost model item = case item of
  ClickerItem c ->
    case (Models.clickerData model c) of
      Nothing ->
        Clickers.cost c 0
      Just data ->
        Clickers.cost c (quantity data)
  UpgradeItem u ->
    Upgrades.cost u

canAfford : Model -> ShopItem -> Bool
canAfford model p = (round model.loc_counter) >= (cost model p)

addClicker : Model -> Clicker -> Model
addClicker model clicker =
  let
    incClicker (c, q, m) =
      if c == clicker then
        (c, q+1, m)
      else
        (c, q, m)
  in
    {model | clickers = List.map incClicker model.clickers}

purchase : Model -> ShopItem -> Model
purchase model item = case item of
  ClickerItem clicker ->
    let
      incClicker clickerData clicker =
        List.map (\(c, q, m) -> if c == clicker then (c, q+1, m) else (c, q, m)) model.clickers
    in
      { model |
        loc_counter = model.loc_counter - (toFloat (cost model (ClickerItem clicker))) --Subtract Cost
      , clickers = incClicker model.clickers clicker --Add 1 to clicker data
      }
  UpgradeItem upgrade ->
    let
      model_ = Models.applyUpgrade model upgrade
    in
      { model_ |
        loc_counter = model.loc_counter - (toFloat (cost model (UpgradeItem upgrade))) --Subtract cost
      , remaining_upgrades = List.filter (\u -> not (u == upgrade)) model.remaining_upgrades --Remove from remaining upgrades
      , active_upgrades = model.active_upgrades ++ [upgrade] --Add to active_upgrades
      }
