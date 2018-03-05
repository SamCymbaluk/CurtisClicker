/*
Takes the actual code for the application and turns it into a list of lines of code
that can be used by Elm
*/
const fs = require('fs');
const path = require('path');

let codeList = [];

fs.readdir("src", (err, files) => {
  if(err) {
      console.error("Could not list the directory.", err);
      return;
  }

  //Put Main.elm in first
  const contents = fs.readFileSync(path.join("src", "Main.elm"), 'utf8');
  codeList.push(...contents.split('\n'));

  files.forEach((file, index) => {
    if (file !== "BackgroundCode.elm" && file !== "Main.elm" && file.endsWith(".elm")) {
      const contents = fs.readFileSync(path.join("src", file), 'utf8');
      codeList.push(...contents.split('\n'));
    }
  });

  codeList = codeList.map(line => escapeRegExp(line));
  //Add quotes and remove EOL "\r"
  codeList = codeList.map(line => "\"" + line.slice(0,-1) + "\"");

  let outputText =
`module BackgroundCode exposing (..)
code : List String
code = ${formatCodeList(codeList)}`

  fs.writeFile("src/BackgroundCode.elm", outputText, (err) => {
    if(err) {
        return console.log(err);
    }
    console.log(`Success! ${codeList.length} lines of code written to BackgroundCode.elm`);
  });
});

//Needed as a workaround to https://github.com/elm-lang/elm-compiler/issues/1521
function formatCodeList(codeList) {
  let codeStr = "[";
  for (let i = 0; i < codeList.length; i += 200) {
    const endIndex = i + 200 >= codeList.length ? codeList.length - 1 : i + 200;

    codeStr += codeList.slice(i, endIndex);
    codeStr += "]++[";
  }
  codeStr += "]";

  return codeStr;
}

function escapeRegExp(text) {
  //Escape quotes and backslashes
  return text.replace(/[\"\\]/g, '\\$&');

  return newText;
}
