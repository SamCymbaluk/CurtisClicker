module Update exposing (..)

import Models exposing (Model)
import CodeEffect
import Storage
import Types exposing (..)
import Msgs exposing (Msg)
import Time exposing (Time, second)
import Effects exposing (EffectObject)
import Bootstrap.Accordion as Accordion
import Bootstrap.Modal as Modal
import Shop
import Random
import Mouse

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Msgs.None ->
          (model, Cmd.none)

        {- Time subscriptions -}
        Msgs.Tick interval time ->
          tick model interval time
        Msgs.AnimTick diff ->
          animTick model diff
        Msgs.SaveInterval interval time ->
          saveInterval model interval time

        Msgs.ApplyModel sModel ->
          applyModel model sModel
        Msgs.MousePos pos ->
          mousePos model pos
        Msgs.Click ->
          click model
        Msgs.Purchase item ->
          purchase model item

        {- Gui/Effects -}
        Msgs.ClickEffects vels ->
          clickEffects model vels
        Msgs.ClickerAccordion state ->
          clickerAccordion model state
        Msgs.UpgradeAccordion state ->
          upgradeAccordion model state
        Msgs.ShowIntroModal ->
          showIntroModal model
        Msgs.CloseIntroModal ->
          closeIntroModal model

tick : Model -> Time -> Time -> (Model, Cmd Msg)
tick model interval time =
  case model.lastTick of
    0 -> -- First tick => Request modal from local storage
      ({ model | lastTick = time }, Storage.loadModel "IshouldntNeedThisStringElm")
    _ ->
      ({ model |
        loc_counter = model.loc_counter + (Models.totalEarnings model (time - model.lastTick))
        , lastTick = time
        }, Cmd.none)

animTick : Model -> Float -> (Model, Cmd Msg)
animTick model diff =
  let
    model2 = CodeEffect.tickCodeEffect model diff
    newModel = if model2.modalOpened then model2 else (\(m, c) -> m) (update Msgs.ShowIntroModal model2)
    oldGui = newModel.gui
    newGui =
      { oldGui
        | effects = Effects.tickEffects oldGui.effects diff }
  in
    ({ newModel | gui = newGui }, Cmd.none)

saveInterval : Model -> Time -> Time -> (Model, Cmd Msg)
saveInterval model interval time =
  (model, Storage.saveModel (Storage.serializeModel model))

applyModel : Model -> Maybe SerializedModel -> (Model, Cmd Msg)
applyModel model sModel =
  (Storage.deserializeModel sModel, Cmd.none)

mousePos : Model -> Mouse.Position -> (Model, Cmd Msg)
mousePos model pos =
  let
    oldGui = model.gui
    newGui = {oldGui | mousePos = { x = pos.x, y = pos.y }}
  in
    ({ model | gui = newGui }, Cmd.none)

click : Model -> (Model, Cmd Msg)
click model =
  let
    newModel = CodeEffect.onClick model
    earnings = Models.formattedLoc newModel.clickEarnings
    foldFn (_, _, q, _) b = q + b
    effectAmt = List.foldr (foldFn) 0 earnings
    oldGui = newModel.gui
    newGui = {oldGui | lastClick = model.lastTick}
  in
    ({ newModel | loc_counter = newModel.loc_counter
                                + newModel.clickEarnings
             , gui = newGui }
     , Random.generate Msgs.ClickEffects (Effects.generateVels effectAmt))

clickEffects : Model -> List (Float, Float) -> (Model, Cmd Msg)
clickEffects model vels =
  let
    oldGui = model.gui
    newGui = {oldGui | effects = oldGui.effects ++ createClickEffects model vels}
  in
    ({ model | gui = newGui }, Cmd.none)

purchase : Model -> ShopItem -> (Model, Cmd Msg)
purchase model item =
  (Shop.purchase model item, Cmd.none)

clickerAccordion : Model -> Accordion.State -> (Model, Cmd Msg)
clickerAccordion model state =
  let
    oldGui = model.gui
    newGui = {oldGui | clickerAccordion = state}
  in
    ({ model | gui = newGui }, Cmd.none)

upgradeAccordion : Model -> Accordion.State -> (Model, Cmd Msg)
upgradeAccordion model state =
  let
    oldGui = model.gui
    newGui = {oldGui | upgradeAccordion = state}
  in
    ({ model | gui = newGui }, Cmd.none)

closeIntroModal : Model -> (Model, Cmd Msg)
closeIntroModal model =
  let
    oldGui = model.gui
    newGui = {oldGui | introModalVis = Modal.hidden}
  in
    ({ model | gui = newGui }, Cmd.none)

showIntroModal : Model -> (Model, Cmd Msg)
showIntroModal model =
  let
    oldGui = model.gui
    newGui = {oldGui | introModalVis = Modal.shown}
  in
    ({ model | modalOpened = True, gui = newGui }, Cmd.none)

{-
  Helper functions
-}

createClickEffects : Model -> List (Float, Float) -> List EffectObject
createClickEffects model vels =
  let
    formattedVels =
      vels
        |> List.map (\(x, y) -> ((x - 0.5), -0.5*y - 0.2))
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
      , img = "img/" ++ img ++ ".png"
      , vel = vel
      , acc = (0, 0.02)
      , ticksToLive = 200
      , height = 20
      , width = 20
      }
  in --At this point, formattedVels and earnings should have the same length
    List.map2 toEffect formattedVels earnings
