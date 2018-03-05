module Util exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Msgs exposing (Msg)

import SyntaxHighlight exposing (useTheme, oneDark, gitHub, elm, toBlockHtml)

formatCode : String -> Html Msg
formatCode codeText =
  div [style [("user-select", "none")]]
    [ useTheme oneDark
    , elm codeText
        |> Result.map (toBlockHtml (Just 1))
        |> Result.withDefault
            (code [] [ text codeText ])
    ]
