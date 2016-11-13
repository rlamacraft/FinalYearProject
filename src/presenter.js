'use strict'
const Elm = require('./presenter_elm.js');
const parser  = require('./parser.js');
const {ipcRenderer} = require('electron');

let container = document.getElementById('container');
let app = Elm.Presenter.embed(container);

ipcRenderer.on("show-pres", (event, message) => {
  try {
    const parsedData = parser.parse(message);
    console.log(parsedData);
    app.ports.parsedData.send(JSON.stringify(parsedData));
  } catch(ex) {
    console.error(ex);
  }
})
