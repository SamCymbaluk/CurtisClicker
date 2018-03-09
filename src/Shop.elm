module Shop exposing (..)

import Models exposing (Model)
import Clickers exposing (clicker, quantity, multiplier)
import Upgrades
import Types exposing (..)

{-| Combines the cost functions of ShopItems -}
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

{-| Updates model with effects of purchasing a ShopItems
Does NOT check to see if ShopItem can be afforded. Use canAfford before calling this function -}
purchase : Model -> ShopItem -> Model
purchase model item = case item of
  ClickerItem clicker ->
    let
      newModel = addClicker model clicker
    in
      { newModel |
        loc_counter = model.loc_counter - (toFloat (cost model (ClickerItem clicker))) --Subtract Cost
      }
  UpgradeItem upgrade ->
    let
      newModel = Upgrades.applyUpgrade model upgrade
    in
      { newModel |
        loc_counter = model.loc_counter - (toFloat (cost model (UpgradeItem upgrade))) --Subtract cost
      , remaining_upgrades = List.filter (\u -> not (u == upgrade)) model.remaining_upgrades --Remove from remaining upgrades
      , active_upgrades = model.active_upgrades ++ [upgrade] --Add to active_upgrades
      }
