module View exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (..)
import Time exposing (Time, second)
import Models exposing (Model)
import Msgs exposing (Msg)
import Shop
import Clickers
import Effects
import Types exposing (..)
import Styles exposing (..)

import FormatNumber exposing (format)
import FormatNumber.Locales exposing (usLocale)

import Bootstrap.Grid as Grid
import Bootstrap.Grid.Row as Row
import Bootstrap.Grid.Col as Col
import Bootstrap.Accordion as Accordion
import Bootstrap.Card as Card
import Bootstrap.Button as Button

view : Model -> Html Msg
view model =
  div [style [("margin", "0px"), ("padding", "0px")]]
      ([ Grid.container [style gridContainer]
        [ Grid.row [Row.attrs [style [("margin", "0px"), ("padding", "0px")]]]
            [ Grid.col [Col.xs3, Col.attrs [style sideCol]]
                [ clickerTitle
                , clickerAccordion model
                ]
            , Grid.col [Col.xs6, Col.attrs [style gridCol]] [ centerDiv model ]
            , Grid.col [Col.xs3, Col.attrs [style sideCol]] [ text (toString model) ]
            ]
        ]
      , earningsPanel model
      ] ++ (Effects.drawEffects model.gui.effects))

centerDiv : Model -> Html Msg
centerDiv model =
  div []
      [ p [style locRateText] [text ((format usLocale (Models.totalEarnings model second)) ++ " LoC/s")]
      , img [src "img/curtis-idle.png", style curtisImg, onClick Msgs.Click] []
      ]

earningsPanel : Model -> Html Msg
earningsPanel model =
  div [style earningPanelDiv]
      [ Grid.container [style gridContainer]
        [ Grid.row [Row.centerXs, Row.attrs [style [("margin", "0px"), ("padding", "0px")]]]
            (List.map (earningCol model) (Models.formattedLoc model.loc_counter))
        ]
      ]

earningCol : Model -> (String, String, Int, String) -> Grid.Column Msg
earningCol model (title, titles, amt, image) =
  Grid.col [Col.xs1, Col.attrs [style earningColumn]]
    [ div []
        [ img [src ("img/earning_icons/" ++ image ++ ".png"), width 50, height 50, style earningIcon] []
        , div []
            [p [style earningText] [text (toString (amt))]]
        ]
    ]


clickerDiv : Model -> ClickerData -> Html Msg
clickerDiv model (c, q, m) =
  div []
      [ text ((toString c) ++ " |#| Cost: " ++ (toString (Clickers.cost c)) ++ " Q: " ++ (toString q) ++ " M: " ++ (toString m))
      , br [] []
      , button [ disabled (not (Shop.canAfford model (ClickerItem c)))
               , onClick (Msgs.Purchase (ClickerItem c)) ]
               [ text "Buy" ]
      , br [] []
      , br [] []
      ]

clickerTitle : Html Msg
clickerTitle =
  div [style sideTitleDiv]
      [ p [style sideTitleText] [text "Auto Clickers"]
      ]

clickerAccordion : Model -> Html Msg
clickerAccordion model =
    Accordion.config Msgs.ClickerAccordion
      |> Accordion.withAnimation
      |> Accordion.cards
        (List.map (clickerCard model) model.clickers)
      |> Accordion.view model.gui.clickerAccordion

clickerCard : Model -> ClickerData -> Accordion.Card Msg
clickerCard model (c, q, m) =
  let
    (cost, costType) = Models.reducedLocFormat (toFloat (Clickers.cost c q))
    (earnings, earningsType) = Models.reducedLocFormat (Clickers.earnings c)
    (totEarnings, totEarningsType) = Models.reducedLocFormat (Models.clickerEarnings model c)
  in
  Accordion.card
    { id = Clickers.name c False
    , options = [Card.attrs [style card]]
    , header =
        Accordion.header [style cardHeader] (Accordion.toggle []
          [ text (Clickers.name c False)
          , span [style [("float", "right")]]
              [ text (toString q) ]
          ])
          |> Accordion.prependHeader
              [ clickerPurchaseButton model (c, q, m) ]
    , blocks =
      [ Accordion.block []
        [ Card.text []
          [ p [style (codeText ++ [("color", darkTheme.text)])]
              [ text ("{- " ++ (Clickers.description c) ++ " -}")]
          , p [style (codeText ++ [("color", darkTheme.text_blue)])]
              [ text "cost"
              , span [style (codeText ++ [("color", darkTheme.text)])]
                  [text " = ("]
              , span [style (codeText ++ [("color", darkTheme.text_orange)])]
                  [text (toString cost)]
              , span [style (codeText ++ [("color", darkTheme.text)])]
                  [text ", "]
              , span [style (codeText ++ [("color", darkTheme.text_green)])]
                  [text ("\"" ++ costType ++ "\"")]
              , span [style (codeText ++ [("color", darkTheme.text)])]
                  [text ")"]
              ]
          , p [style (codeText ++ [("color", darkTheme.text_blue)])]
              [ text "baseEarnings"
              , span [style (codeText ++ [("color", darkTheme.text)])]
                  [text " = ("]
              , span [style (codeText ++ [("color", darkTheme.text_orange)])]
                  [text (toString earnings)]
              , span [style (codeText ++ [("color", darkTheme.text)])]
                  [text ", "]
              , span [style (codeText ++ [("color", darkTheme.text_green)])]
                  [text ("\"" ++ earningsType ++ "\"")]
              , span [style (codeText ++ [("color", darkTheme.text)])]
                  [text ")"]
              ]
          , p [style (codeText ++ [("color", darkTheme.text_blue)])]
              [ text "earningMultiplier"
              , span [style (codeText ++ [("color", darkTheme.text)])]
                  [text " = "]
              , span [style (codeText ++ [("color", darkTheme.text_orange)])]
                  [text (toString (m))]
              ]
          , p [style (codeText ++ [("color", darkTheme.text_blue)])]
              [ text "totalEarnings"
              , span [style (codeText ++ [("color", darkTheme.text)])]
                  [text " = ("]
              , span [style (codeText ++ [("color", darkTheme.text_orange)])]
                  [text (toString totEarnings)]
              , span [style (codeText ++ [("color", darkTheme.text)])]
                  [text ", "]
              , span [style (codeText ++ [("color", darkTheme.text_green)])]
                  [text ("\"" ++ totEarningsType ++ "\"")]
              , span [style (codeText ++ [("color", darkTheme.text)])]
                  [text ")"]
              ]
          ]
        ]
      ]
    }

clickerPurchaseButton : Model -> ClickerData -> Html Msg
clickerPurchaseButton model (c, q, m) =
   Button.button
    [ Button.small
    , Button.primary
    , Button.disabled (not (Shop.canAfford model (ClickerItem c)))
    , Button.attrs
        [ onClick (Msgs.Purchase (ClickerItem c))
        , style purchaseButton
        ]
    ]
    [ text "+" ]
