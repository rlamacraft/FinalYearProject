'use strict'
const Elm = require('./editor_elm.js');
const {ipcRenderer} = require('electron');
const fs = require('fs');
const {dialog} = require('electron').remote;

let container = document.getElementById('container');
let app = Elm.Editor.embed(container);
let windowIndex;
let currentFile;

app.ports.parseText.subscribe(function(text) {
  ipcRenderer.send('show-pres', windowIndex, text);
});

app.ports.requestFile.subscribe(function() {
  const dialogOptions = {
    title: "Load Input File",
    properties: ['openFile']
  };

  dialog.showOpenDialog(dialogOptions, function(filenames) {
    if(typeof(filenames) === "undefined")
      return;
    if(filenames.length > 1) {
      alert("Can only load one file!")
    } else {
      currentFile = filenames[0];
      fs.readFile(currentFile, function(err, data) {
        app.ports.fileData.send(data.toString());
      });
    }
  });
});

app.ports.createWindow.subscribe(function() {
  ipcRenderer.send('new-window');
});

app.ports.writeToFile.subscribe(function(text) {
  fs.writeFile(currentFile, text);
});

// as part of an Editor window init, an index will be generated for associating its presentation window
ipcRenderer.once("window-pair-index", (event, newWindowIndex) => {
  windowIndex = newWindowIndex;
});
