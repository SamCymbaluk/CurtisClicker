'use strict';

//require('ace-css/css/ace.css');
require('font-awesome/css/font-awesome.css');

// Require index.html so it gets copied to dist
require('./index.html');

// Webpack is weeiird
function requireAll(r) { r.keys().forEach(r); }
requireAll(require.context('../img/', true));

var Elm = require('./Main.elm');
var mountNode = document.getElementById('main');

// .embed() can take an optional second argument. This would be an object describing the data we need to start a program, i.e. a userID or some token
var app = Elm.Main.embed(mountNode);

app.ports.saveModel.subscribe(function(model) {
    localStorage.setItem('elm-model', JSON.stringify(model));
});

app.ports.loadModel.subscribe(function() {
  app.ports.loadModelRes.send(JSON.parse(localStorage.getItem('elm-model')));
});
