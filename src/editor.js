'use strict'
const Elm = require('./editor_elm.js');

// get a reference to the div where we will show our UI
let container = document.getElementById('container');

// start the elm app in the container
// and keep a reference for communicating with the app
let app = Elm.Editor.embed(container);

app.ports.textOut.subscribe(function(text) {
  console.log(text);
  app.ports.textIn.send(text + "!");
});
