module Update exposing (..)

import Models exposing (Model)
import Storage
import Msgs exposing (Msg)
import Time exposing (Time, second)
import Effects exposing (EffectObject)
import Shop
import Random

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
        Msgs.AnimTick diff ->
          let
            oldGui = model.gui
            newGui =
              { oldGui
                | effects = Effects.tickEffects oldGui.effects diff }
          in
            ({ model | gui = newGui }, Cmd.none)
        Msgs.SaveInterval interval time ->
          (model, Storage.saveModel (Storage.serializeModel model))
        Msgs.ApplyModel sModel ->
          (Storage.deserializeModel sModel, Cmd.none)
        Msgs.MousePos pos ->
          let
            oldGui = model.gui
            newGui = {oldGui | mousePos = { x = pos.x, y = pos.y }}
          in
            ({ model | gui = newGui }, Cmd.none)
        Msgs.Click ->
          let
            earnings = Models.formattedLoc model.clickEarnings
            foldFn (_, _, q, _) b = q + b
            effectAmt = List.foldr (foldFn) 0 earnings
          in
            ({ model | loc_counter = model.loc_counter + model.clickEarnings }
             , Random.generate Msgs.ClickEffects (Effects.generateVels effectAmt))
        Msgs.ClickEffects vels ->
          let
            oldGui = model.gui
            newGui = {oldGui | effects = oldGui.effects ++ clickEffects model vels}
          in
            ({ model | gui = newGui }, Cmd.none)
        Msgs.Purchase item ->
          (Shop.purchase model item, Cmd.none)
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


clickEffects : Model -> List (Float, Float) -> List EffectObject
clickEffects model vels =
  let
    formattedVels =
      vels
        |> List.map (\(x, y) -> (1 * (x - 0.5), 1 * (y - 0.5)))
    earnings =
      Models.formattedLoc model.clickEarnings
        |> List.filter (\(_, _, q, _) -> q /= 0)
        |> List.foldr (\e l -> l ++ expandEarning e) []
    expandEarning (s, ss, q, img) =
      if q <= 1 then
        [(s, ss, q, img)]
      else
        [(s, ss, q, img)] ++ (expandEarning (s, ss, q - 1, img))
    toEffect vel (_, _, _, img) =
      { x = toFloat model.gui.mousePos.x
      , y = toFloat model.gui.mousePos.y
      , img = "img/earning_icons/" ++ img ++ ".png"
      , vel = vel
      , acc = (0, 0.02)
      , ticksToLive = 200
      , height = 20
      , width = 20
      }
  in --At this point, formattedVels and earnings should have the same length
    List.map2 toEffect formattedVels earnings
