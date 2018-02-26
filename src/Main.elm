module Main exposing (..)

import Html exposing (program)
import Msgs exposing (Msg)
import Models exposing (Model, init)
import Storage exposing (loadModelRes)
import Update exposing (update)
import View exposing (view)
import Time exposing (Time, second)
import Bootstrap.Accordion as Accordion

tickRate : Time
tickRate = second / 30

{- Subscriptions -}
subscriptions : Model -> Sub Msg
subscriptions model = Sub.batch
  [ Time.every tickRate (Msgs.Tick tickRate)
  , Time.every (second * 10) (Msgs.SaveInterval (second * 10))
  , Accordion.subscriptions model.gui.clickerAccordion Msgs.ClickerAccordion
  , Accordion.subscriptions model.gui.upgradeAccordion Msgs.UpgradeAccordion
  , loadModelRes Msgs.ApplyModel
  ]

{- Main -}
main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
