module CodeEffect exposing (..)

import BackgroundCode
import Models exposing (Model)
import Time exposing (Time, second)
import Html exposing (..)
import Html.Attributes exposing (..)
import Msgs exposing (Msg)
import Util exposing (formatCode)

tickCodeEffect : Model -> Time -> Model
tickCodeEffect model diff =
  let
    oldGui = model.gui
    newBgCodeLines =
      if (oldGui.bgCodeLines + (locSpeed model diff)) > 20
        then 20
        else oldGui.bgCodeLines + (locSpeed model diff)
    newBgCodeIndex =
      if (toFloat oldGui.bgCodeIndex + (locSpeed model diff)) > toFloat ((List.length BackgroundCode.code) - 20)
        then (List.length BackgroundCode.code) - 20
        else round (oldGui.bgCodeLines + (locSpeed model diff))
    newGui = {oldGui | bgCodeLines = newBgCodeLines, bgCodeIndex = newBgCodeIndex }
  in
    { model | gui = newGui }

onClick : Model -> Model
onClick model =
  let
    oldGui = model.gui
    newBgCodeLines =
      if (oldGui.bgCodeLines + 1) > 20
        then 20
        else oldGui.bgCodeLines + 1
    newBgCodeIndex =
      if (oldGui.bgCodeIndex + 1) > (List.length BackgroundCode.code) - 20
        then (List.length BackgroundCode.code) - 20
        else  round (oldGui.bgCodeLines + 1)
    newGui = {oldGui | bgCodeLines = newBgCodeLines, bgCodeIndex = newBgCodeIndex }
  in
    { model | gui = newGui }

codeDiv : Model -> Html Msg
codeDiv model =
  let
    lines = BackgroundCode.code
      |> List.drop model.gui.bgCodeIndex
      |> List.take (round model.gui.bgCodeLines)
      |> String.join "\n"
  in
    div
      [style [("position", "absolute"), ("left", "0px"), ("top", "0px")]]
      [formatCode lines]


locSpeed : Model -> Time -> Float
locSpeed model diff =
  let
    earnings = Models.totalEarnings model diff
  in
    (2 * (logBase 2 ((earnings + 5000) / 5000))) / (second / diff)
