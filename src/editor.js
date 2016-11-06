'use strict'
const Elm = require('./editor_elm.js');
const parser  = require('./parser.js');
const {ipcRenderer} = require('electron');

// get a reference to the div where we will show our UI
let container = document.getElementById('container');

// start the elm app in the container
// and keep a reference for communicating with the app
let app = Elm.Editor.embed(container);

app.ports.parseText.subscribe(function(text) {
  try {
    const parsedData = parser.parse(text);
    console.log(parsedData);
    const JsonParsedData = JSON.stringify(parsedData)
    app.ports.parsedData.send(JsonParsedData);
    ipcRenderer.send('show-pres', JsonParsedData);
  } catch(ex) {
    console.error(ex);
  }
});
