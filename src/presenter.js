'use strict'
const Elm = require('./presenter_elm.js');
const {ipcRenderer} = require('electron');

// get a reference to the div where we will show our UI
let container = document.getElementById('container');

// start the elm app in the container
// and keep a reference for communicating with the app
let app = Elm.Presenter.embed(container);

ipcRenderer.on("show-pres", (event, message) => {
  app.ports.parsedData.send(message);
})
