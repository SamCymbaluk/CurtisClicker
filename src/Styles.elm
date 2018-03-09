module Styles exposing (..)

darkTheme :
  { background : String
  , sidebar : String
  , text : String
  , text_blue : String
  , text_orange : String
  , text_green : String
  , textbox : String
  }
darkTheme =
  { background = "#282C34"
  , sidebar = "#21232b"
  , text = "#ABAEBF"
  , text_blue = "#61AFEF"
  , text_orange = "#D19A66"
  , text_green = "#98C379"
  , textbox = "#d1d1e0"
  }

gridContainer : List (String, String)
gridContainer =
   [ ("padding", "0px")
   , ("margin", "0px")
   , ("width", "100vw")
   ]

gridCol : List (String, String)
gridCol =
  [ ("height", "100vh")
  , ("padding", "0px")
  , ("background-color", darkTheme.background)
  ]

{- Sidebar -}

sideCol : List (String, String)
sideCol = gridCol ++
  [ ("border-left", "2px solid black")
  , ("border-right", "2px solid black")
  , ("background-color", darkTheme.sidebar)
  , ("overflow-y", "auto")
  ]

sideTitleDiv : List (String, String)
sideTitleDiv =
  [ ("border-bottom", "2px solid " ++ darkTheme.text)
  , ("margin-top", "1rem")
  ]

sideTitleText : List (String, String)
sideTitleText =
  [ ("text-align", "center")
  , ("font-family", "Fira Mono")
  , ("font-size", "24px")
  , ("color", "white")
  ]

{- Center -}

centerDivStyle : List (String, String)
centerDivStyle =
  [ ("height", "100%")
  , ("overflow-y", "hidden")
  ]

curtisImg : List (String, String)
curtisImg =
  [ ("position", "fixed")
  , ("left", "50vw")
  , ("top", "40vh")
  , ("margin-left", "-15vh")
  , ("margin-top", "-15vh")
  , ("width", "30vh")
  , ("z-index", "10")
  ]

locRateDiv : List (String, String)
locRateDiv =
  [ ("position", "fixed")
  , ("width", "100%")
  , ("left", "0vw")
  , ("top", "25vh")
  , ("pointer-events", "none")
  ]

locRateText : List (String, String)
locRateText =
  [ ("margins", "auto")
  , ("text-align", "center")
  , ("font-family", "Fira Mono")
  , ("font-size", "32px")
  , ("color", darkTheme.text)
  ]

clickEarningsDiv : List (String, String)
clickEarningsDiv =
  [ ("position", "fixed")
  , ("width", "100%")
  , ("left", "0vw")
  , ("top", "56vh")
  , ("pointer-events", "none")
  ]

clickEarningsText : List (String, String)
clickEarningsText =
  [ ("margins", "auto")
  , ("text-align", "center")
  , ("font-family", "Fira Mono")
  , ("font-size", "24px")
  , ("color", darkTheme.text)
  ]

{- Earnings panel -}

earningPanelDiv : List (String, String)
earningPanelDiv =
  [ ("margin", "auto")
  , ("padding", "0px")
  , ("position", "fixed")
  , ("bottom", "0px")
  , ("width", "100vw")
  , ("pointer-events", "none")
  ]

earningIcon : List (String, String)
earningIcon =
  [ ("display", "block")
  , ("margin", "0 auto")
  ]

earningColumn : List (String, String)
earningColumn =
  [ ("padding-top", "15px")
  , ("background-color", "#2d2f39")
  , ("border", "1px solid black")
  ]

earningText : List (String, String)
earningText =
  [ ("text-align", "center")
  , ("font-family", "Fira Mono")
  , ("font-size", "24px")
  , ("color", darkTheme.text)
  , ("margin", "5px")
  ]

{- Misc -}

cardHeader : List (String, String)
cardHeader =
  [ ("background-color", "#2d2f39")
  ]

card : List (String, String)
card =
  [ ("border", "0")
  , ("background-color", darkTheme.background)
  , ("border-bottom", "1px solid " ++ darkTheme.text)
  ]

codeText : List (String, String)
codeText =
  [ ("font-family", "Fira Mono")
  , ("font-size", "12px")
  , ("margin", "3px")
  , ("margin-left", "0px")
  , ("margin-right", "0px")
  ]

purchaseButton : List (String, String)
purchaseButton =
  [ ("margin-right", "1rem")
  , ("padding", "4px")
  ]
