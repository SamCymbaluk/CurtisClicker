/*
Takes the actual code for the application and turns it into a list of lines of code
that can be used by Elm
*/
const fs = require('fs');
const path = require('path');

//Beginner code for an Elm app so that the first LoC are "basic"
const initialCode=
`module CurtisClicker exposing (..)
{-
Title: CurtisClicker
Author: Sam Cymbaluk
Created for: CS1XA3 at McMaster
-}

import Html exposing (..)
import Html.App as Html

-- MODEL
type alias Model =
  { value : Int
  }

model : Model
model =
  { value = 0
  }

-- UPDATE
type Msg
  = NoOp

update: Msg -> Model -> Model
update msg model =
  case msg of
    NoOp ->
      model

-- VIEW
view : Model -> Html Msg
view model =
  p [] [ text <| toString model.value ]

-- APP
main =
  Html.beginnerProgram
    { model = model
    , view = view
    , update = update
    }
`

let codeList = initialCode.split('\n')

fs.readdir("src", (err, files) => {
  if(err) {
      console.error("Could not list the directory.", err);
      return;
  }

  files.forEach((file, index) => {
    if (file !== "BackgroundCode.elm" && file.endsWith(".elm")) {
      const contents = fs.readFileSync(path.join("src", file), 'utf8');
      codeList.push(...contents.split('\n'));
    }
  });

  codeList = codeList.map(line => escapeRegExp(line));
  //Add quotes and remove EOL "\r"
  codeList = codeList.map(line => "\"" + line.slice(0,-1) + "\"");

  if (codeList.length > 500) { //TODO figure out why more that 500 loc breaks webpack
    codeList = codeList.splice(0, 500);
  }

  let outputText =
`module BackgroundCode exposing (..)
code : List String
code = [${codeList.join(',')}]`

  fs.writeFile("src/BackgroundCode.elm", outputText, (err) => {
    if(err) {
        return console.log(err);
    }
    console.log(`Success! ${codeList.length} lines of code written to BackgroundCode.elm`);
  });
});

function escapeRegExp(text) {
  //Escape quotes and backslashes
  return text.replace(/[\"\\]/g, '\\$&');

  return newText;
}
