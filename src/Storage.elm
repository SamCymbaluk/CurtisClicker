port module Storage exposing (..)

import Models exposing (Model, init)
import Clickers
import Upgrades
import Types exposing (..)
import Maybe.Extra

-- Save model to local storage
port saveModel : SerializedModel -> Cmd msg

-- Request model from local storage (string is useless and unused but necessary to compile)
port loadModel : String -> Cmd msg

-- Accept model from JavaScript
port loadModelRes : (Maybe SerializedModel -> msg) -> Sub msg

{-| Takes data (i.e. not gui) portion of Model and
converts to serializable types when necessary -}
serializeModel : Model -> SerializedModel
serializeModel model =
  { loc_counter = model.loc_counter
  , clickers = serializeClickers model.clickers
  , lastTick = model.lastTick
  , clickEarnings = model.clickEarnings
  , remaining_upgrades = serializeUpgrades model.remaining_upgrades
  , active_upgrades = serializeUpgrades model.active_upgrades
  , modalOpened = model.modalOpened
  }

{-| Intecects SerializedModel with initial model -}
deserializeModel : Maybe SerializedModel -> Model
deserializeModel serializedModel =
  let
    (model, _) = init
  in
    case serializedModel of
      Just sModel ->
        { model
          | loc_counter = sModel.loc_counter
          , clickers = deserializeClickers sModel.clickers
          , lastTick = sModel.lastTick
          , clickEarnings = sModel.clickEarnings
          , remaining_upgrades = deserializeUpgrades sModel.remaining_upgrades
          , active_upgrades = deserializeUpgrades sModel.active_upgrades
          , modalOpened = sModel.modalOpened
        }
      Nothing ->
        model

serializeClickers : List ClickerData -> List (Int, Int, Float)
serializeClickers cd =
  let
    convert (c, q, m) = (Clickers.toInt c, q, m)
  in
    List.map convert cd

deserializeClickers : List (Int, Int, Float) -> List ClickerData
deserializeClickers scd =
  let
    convert (cId, q, m) =
      let
        maybeClicker = Clickers.fromInt cId
      in
        case maybeClicker of
          Just c -> Just (c, q, m)
          Nothing -> Nothing
  in
    Maybe.Extra.values (List.map convert scd)

serializeUpgrades : List Upgrade -> List Int
serializeUpgrades upgrades = List.map (\u -> Upgrades.toInt u) upgrades

deserializeUpgrades : List Int -> List Upgrade
deserializeUpgrades ints =
  let
    convert i = case (Upgrades.fromInt i) of
      Just u -> Just u
      Nothing -> Nothing
  in
    Maybe.Extra.values (List.map convert ints)
