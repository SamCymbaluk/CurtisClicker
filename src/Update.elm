module Update exposing (..)

import Models exposing (Model)
import Storage
import Msgs exposing (Msg)
import Time exposing (Time, second)
import Shop

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Msgs.None ->
          (model, Cmd.none)
        Msgs.Tick interval time ->
          case model.lastTick of
            0 ->
              ({ model | lastTick = time }, Storage.loadModel "IshouldntNeedThisStringElm")
            _ ->
              ({ model |
                loc_counter = model.loc_counter + (Models.totalEarnings model (time - model.lastTick))
                , lastTick = time
                }, Cmd.none)
        Msgs.Click ->
          ({ model | loc_counter = model.loc_counter + 1 }, Cmd.none)
        Msgs.Purchase item ->
          (Shop.purchase model item, Cmd.none)
        Msgs.SaveInterval interval time ->
          (model, Storage.saveModel (Storage.serializeModel model))
        Msgs.ApplyModel sModel ->
          (Storage.deserializeModel sModel, Cmd.none)
        Msgs.ClickerAccordion state ->
          let
            oldGui = model.gui
            newGui = {oldGui | clickerAccordion = state}
          in
            ({ model | gui = newGui }, Cmd.none)
        Msgs.UpgradeAccordion state ->
          let
            oldGui = model.gui
            newGui = {oldGui | upgradeAccordion = state}
          in
            ({ model | gui = newGui }, Cmd.none)
