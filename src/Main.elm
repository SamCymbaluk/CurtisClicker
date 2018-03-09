module Main exposing (..)

import Html exposing (program)
import Msgs exposing (Msg)
import Models exposing (Model, init)
import Storage exposing (loadModelRes)
import Update exposing (update)
import View exposing (view)
import Time exposing (Time, second)
import Bootstrap.Accordion as Accordion
import AnimationFrame as Anim
import Mouse

---------------------------------------
-- CurtisClicker                     --
-- Author: Sam Cymbaluk              --
-- Created for: CS 1XA3 at McMaster  --
---------------------------------------

tickRate : Time
tickRate = second / 30

{- Subscriptions -}
subscriptions : Model -> Sub Msg
subscriptions model = Sub.batch
  [ Time.every tickRate (Msgs.Tick tickRate)
  , Anim.diffs Msgs.AnimTick
  , Time.every (second * 10) (Msgs.SaveInterval (second * 10))
  , Accordion.subscriptions model.gui.clickerAccordion Msgs.ClickerAccordion
  , Accordion.subscriptions model.gui.upgradeAccordion Msgs.UpgradeAccordion
  , loadModelRes Msgs.ApplyModel
  , Mouse.moves Msgs.MousePos
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
