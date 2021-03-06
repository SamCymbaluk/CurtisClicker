module View exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (..)
import Time exposing (Time, second)
import Models exposing (Model)
import Msgs exposing (Msg)
import CodeEffect
import Shop
import Clickers
import Upgrades
import Effects
import Types exposing (..)
import Styles exposing (..)
import Util exposing (formatCode)

import FormatNumber exposing (format)
import FormatNumber.Locales exposing (usLocale)

import Bootstrap.Grid as Grid
import Bootstrap.Grid.Row as Row
import Bootstrap.Grid.Col as Col
import Bootstrap.Accordion as Accordion
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Button as Button
import Bootstrap.Modal as Modal

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
            , Grid.col [Col.xs3, Col.attrs [style sideCol]]
                [ upgradesTitle
                , upgradesAccordion model
                ]
            ]
        ]
      , earningsPanel model
      , introModal model
      ] ++ (Effects.drawEffects model.gui.effects))

centerDiv : Model -> Html Msg
centerDiv model =
  div [style centerDivStyle]
      [ CodeEffect.codeDiv model
      , curtisDiv model
      , div [style locRateDiv] [p [style locRateText] [text ((format usLocale (Models.totalEarnings model second)) ++ " LoC/s")]]
      , div [style clickEarningsDiv] [p [style clickEarningsText] [text ((format usLocale model.clickEarnings) ++ " LoC/click")]]
      ]

curtisDiv : Model -> Html Msg
curtisDiv model =
  let
    locs = Models.totalEarnings model second
    curtisLevel =
      if locs < 1.0 then
        1
      else if locs < 100.0 then
        2
      else if locs < 5000.0 then
        3
      else if locs < 100000.0 then
        4
      else if locs < 500000.0 then
        5
      else if locs < 1000000.0 then
        6
      else
        7
    level = Basics.min 7 (if model.lastTick - model.gui.lastClick > second * 1 then curtisLevel else curtisLevel + 1)
  in
    img [ src ("img/curtis-" ++ toString level ++ ".png")
        , draggable "false"
        , id "curtis"
        , style curtisImg
        , class "hvr-grow"
        , onClick Msgs.Click] []

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
        [ img [src ("img/" ++ image ++ ".png"), width 50, height 50, style earningIcon] []
        , div []
            [p [style earningText] [text (toString (amt))]]
        ]
    ]

clickerTitle : Html Msg
clickerTitle =
  div [style sideTitleDiv]
      [ p [style sideTitleText] [text "Auto Clickers"]
      ]

upgradesTitle : Html Msg
upgradesTitle =
  div [style sideTitleDiv]
      [ p [style sideTitleText] [text "Upgrades"]
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
        [ Block.text []
          [ formatCode <|
            "{- " ++ (Clickers.description c) ++ " -}\n" ++
            "cost = (" ++ (toString cost) ++ ", \"" ++ costType ++ "\")\n" ++
            "baseEarnings = (" ++ (toString earnings) ++ ", \"" ++ earningsType ++ "\")\n\n" ++
            "earningMultiplier = " ++ (toString m) ++ "\n" ++
            "totalEarnings = (" ++ (toString totEarnings) ++ ", \"" ++ totEarningsType ++ "\")\n"
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

upgradesAccordion : Model -> Html Msg
upgradesAccordion model =
    Accordion.config Msgs.UpgradeAccordion
      |> Accordion.withAnimation
      |> Accordion.cards
        (List.map (upgradeCard model) (List.filter (Upgrades.unlocked model) model.remaining_upgrades))
      |> Accordion.view model.gui.upgradeAccordion

upgradeCard : Model -> Upgrade -> Accordion.Card Msg
upgradeCard model upgrade =
  let
    (cost, costType) = Models.reducedLocFormat (toFloat (Upgrades.cost upgrade))
    (clickers, m, clickM) = Upgrades.modifiers upgrade
  in
    Accordion.card
      { id = toString upgrade
      , options = [Card.attrs [style card]]
      , header =
          Accordion.header [style cardHeader] (Accordion.toggle []
            [ text (Upgrades.name upgrade)
            , span [style [("float", "right")]]
                [ upgradePurchaseButton model upgrade ]
            ])
      , blocks =
        [ Accordion.block []
          [ Block.text []
            [ formatCode <|
              "{- " ++ (Upgrades.description upgrade) ++ " -}\n" ++
              "cost = (" ++ (toString cost) ++ ", \"" ++ costType ++ "\")\n\n" ++
              "clickMultiplier = " ++ (toString clickM) ++ "\n\n" ++
              "earningBoost = \"" ++ (toString (m * 100)) ++ "%\"\n" ++
              "affectedClickers =" ++
                if clickers == clickerList then
                  " All"
                else
                  " Only\n  [ "
                  ++ (String.join "\n  , " (List.map (\c -> "\"" ++ (Clickers.name c True) ++ "\"") clickers))
                  ++ "\n  ]"
            ]
          ]
        ]
      }

upgradePurchaseButton : Model -> Upgrade -> Html Msg
upgradePurchaseButton model upgrade =
   Button.button
    [ Button.small
    , Button.primary
    , Button.disabled (not (Shop.canAfford model (UpgradeItem upgrade)))
    , Button.attrs
        [ onClick (Msgs.Purchase (UpgradeItem upgrade))
        , style purchaseButton
        ]
    ]
    [ text "Purchase" ]

introModal : Model -> Html Msg
introModal model =
  Modal.config Msgs.CloseIntroModal
    |> Modal.large
    |> Modal.hideOnBackdropClick False
    |> Modal.h3 [style sideTitleText] [ text "Curtis Clicker" ]
    |> Modal.body [] [ introModalDiv model ]
    |> Modal.footer []
      [ Button.button
        [ Button.outlinePrimary
        , Button.attrs [ onClick Msgs.CloseIntroModal ]
        ]
        [ text "Let's go!" ]
      ]
    |> Modal.view model.gui.introModalVis

introModalDiv : Model -> Html Msg
introModalDiv model =
  div [style modalText]
  [ p [style [("font-size", "16px")]] [text "Meet Curtis:"]
  , img [src "img/intro-curtis.png", style [("margin","auto"), ("display","block")]] []
  , p []
      [
        text <| "Curtis is a Computer Science student at McMaster with a bright future ahead of him! "
          ++ "Unfortuately, Curtis sometimes has difficulty staying on task and getting his work done. "
          ++ "\"Encourage\" him to write code by "
      , strong [] [text "clicking"]
      , text <| " on him. "
          ++ "Once he has written enough code, you can automate the process by purchasing "
      , strong [] [text "Auto Clickers. "]
      , text "You can also purchase "
      , strong [] [text "Upgrades"]
      , text " which augment your clicks and Auto Clicker earnings."
      ]
  ]
