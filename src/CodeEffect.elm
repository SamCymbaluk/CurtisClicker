module CodeEffect exposing (..)

import BackgroundCode
import Models exposing (Model)
import Time exposing (Time, second)
import Html exposing (..)
import Html.Attributes exposing (..)
import Msgs exposing (Msg)
import Util exposing (formatCode)

lineHeight : Float
lineHeight = 20

totalLines : Int
totalLines = 35

tickCodeEffect : Model -> Time -> Model
tickCodeEffect model diff =
  codeEffect model (locSpeed model diff)

onClick : Model -> Model
onClick model = codeEffect model lineHeight


codeEffect : Model -> Float -> Model
codeEffect model movement =
  let
    oldGui = model.gui
    absPos = oldGui.bgCodePos + movement
    dIndex = floor (absPos / lineHeight)
    finalPos = absPos - ((toFloat dIndex) * lineHeight)
    finalIndex = rem (oldGui.bgCodeIndex + dIndex) (List.length BackgroundCode.code - totalLines)
    newGui = { oldGui | bgCodePos = finalPos, bgCodeIndex = finalIndex }
  in
    {model | gui = newGui }

codeDiv : Model -> Html Msg
codeDiv model =
  let
    lines = BackgroundCode.code
      |> List.drop model.gui.bgCodeIndex
      |> List.take totalLines
      |> String.join "\n"
  in
    div
      [style (("top", "-" ++ toString (model.gui.bgCodePos) ++ "px")::codeDivStyle)]
      [formatCode lines]

codeDivStyle : List (String, String)
codeDivStyle =
  [ ("position", "absolute")
  , ("left", "0px")
  , ("-webkit-filter", "blur(2px)")
  , ("-moz-filter", "blur(2px)")
  , ("-o-filter", "blur(2px)")
  , ("-ms-filter", "blur(2px)")
  , ("filter", "blur(2px)")
  ]

locSpeed : Model -> Time -> Float
locSpeed model diff =
  let
    earnings = Models.totalEarnings model diff
  in
    if earnings >= 0 then
      1 + (100 * (logBase 2 ((earnings + 2500) / 2500))) * (diff / second)
    else
      0
