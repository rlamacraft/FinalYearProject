'use strict'
const Elm = require('./presenter_elm.js');
const parser  = require('./parser.js');
const {ipcRenderer} = require('electron');

let container = document.getElementById('container');
let app = Elm.Presenter.embed(container);

ipcRenderer.on("show-pres", (event, message) => {
  try {
    const currentFile = message.currentFile;
    const indexOfFileName = currentFile.lastIndexOf("/");
    const currentDirectory = currentFile.substring(0,indexOfFileName);
    document.getElementById("currentDirectory").setAttribute("data-directory",currentDirectory);

    const parsedData = parser.parse(message.data);
    console.log(parsedData);
    app.ports.parsedData.send(JSON.stringify(parsedData));
  } catch(ex) {
    console.error(ex);
  }
})
