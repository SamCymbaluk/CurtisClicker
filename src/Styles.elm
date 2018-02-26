module Styles exposing (..)

import Html exposing (..)

darkTheme =
  { background = "#282A34"
  , sidebar = "#21232b"
  , text = "#ABAEBF"
  , text_blue = "#61AFEF"
  , text_orange = "#D19A66"
  , text_green = "#98C379"
  , textbox = "#d1d1e0"
  }

gridContainer =
   [ ("padding", "0px")
   , ("margin", "0px")
   , ("width", "100vw")
   ]

gridCol =
  [ ("height", "100vh")
  , ("padding", "0px")
  , ("background-color", darkTheme.background)
  ]

{- Sidebar -}

sideCol = gridCol ++
  [ ("border-left", "2px solid black")
  , ("border-right", "2px solid black")
  , ("background-color", darkTheme.sidebar)
  , ("overflow-y", "auto")
  ]

sideTitleDiv =
  [ ("border-bottom", "2px solid " ++ darkTheme.text)
  ]

sideTitleText =
  [ ("text-align", "center")
  , ("font-family", "Fira Mono")
  , ("font-size", "24px")
  , ("color", "white")
  ]

{- Center -}

curtisImg =
  [ ("display", "block")
  , ("margin-top", "-80px")
  , ("margin-left", "auto")
  , ("margin-right", "auto")
  , ("width", "25%")
  ]

locRateText =
  [ ("text-align", "center")
  , ("font-family", "Fira Mono")
  , ("font-size", "32px")
  , ("color", darkTheme.text)
  , ("margin-top", "180px")
  ]

{- Earnings panel -}

earningPanelDiv =
  [ ("margin", "auto")
  , ("padding", "0px")
  , ("position", "fixed")
  , ("bottom", "0px")
  , ("width", "100vw")
  ]

earningIcon =
  [ ("display", "block")
  , ("margin", "0 auto")
  ]

earningColumn =
  [ ("padding-top", "15px")
  , ("background-color", "#2d2f39")--"#4f5164")
  , ("border", "1px solid black")
  , ("border-radius", "5px")
  , ("box-shadow", "0 4px 8px 0 rgba(0, 0, 0, 0.4), 0 6px 20px 0 rgba(0, 0, 0, 0.4)")
  ]

earningText =
  [ ("text-align", "center")
  , ("font-family", "Fira Mono")
  , ("font-size", "24px")
  , ("color", darkTheme.text)
  , ("margin", "5px")
  ]

{- Misc -}

cardHeader =
  [ ("background-color", "#2d2f39")
  ]

card =
  [ ("border", "0")
  , ("background-color", darkTheme.background)
  , ("border-bottom", "1px solid " ++ darkTheme.text)
  ]

codeText =
  [ ("font-family", "Fira Mono")
  , ("font-size", "12px")
  , ("margin", "3px")
  , ("margin-left", "0px")
  , ("margin-right", "0px")
  ]
