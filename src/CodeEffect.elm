module CodeEffect exposing (..)

import BackgroundCode
import Models exposing (Model)
import Time exposing (Time, second)
import Html exposing (..)
import Html.Attributes exposing (..)
import Msgs exposing (Msg)
import Util exposing (formatCode)

-- Font size + padding = 20
lineHeight : Float
lineHeight = 20

totalLines : Int
totalLines = 45

{-| Applies time based code effect -}
tickCodeEffect : Model -> Time -> Model
tickCodeEffect model diff =
  codeEffect model (locSpeed model diff)

{-| Applies clicked based code effect -}
onClick : Model -> Model
onClick model = codeEffect model lineHeight

{-| Applies movement to codeEffect -}
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

{-| The Html element of the codeEffect with
the correct code lines and positioning -}
codeDiv : Model -> Html Msg
codeDiv model =
  let
    lines = BackgroundCode.code
      |> List.drop model.gui.bgCodeIndex
      |> List.take totalLines
      |> String.join "\n"
  in
    div
      [style (("margin-top", "-" ++ toString (model.gui.bgCodePos) ++ "px")::codeDivStyle)]
      [formatCode lines]

codeDivStyle : List (String, String)
codeDivStyle =
  [ ("width", "100%")
  , ("-webkit-filter", "blur(2px)")
  , ("-moz-filter", "blur(2px)")
  , ("-o-filter", "blur(2px)")
  , ("-ms-filter", "blur(2px)")
  , ("filter", "blur(2px)")
  ]

{-| Converts LoC earnings to speed code "falls"
Uses log to prevent insane earnings from breaking everything -}
locSpeed : Model -> Time -> Float
locSpeed model diff =
  let
    earnings = Models.totalEarnings model diff
  in
    if earnings > 0 then
      0.2 + (100 * (logBase 2 ((earnings + 2500) / 2500))) * (diff / second)
    else
      0
