'use strict'
const Elm = require('./editor_elm.js');
const {ipcRenderer} = require('electron');
const fs = require('fs');
const {dialog} = require('electron').remote;

let container = document.getElementById('container');
let app = Elm.Editor.embed(container);
let windowIndex;
let currentFile = "";

app.ports.parseText.subscribe(function(text) {
  ipcRenderer.send('show-pres', windowIndex, text);
});

/*
* Open a file and load its contents into the Editor Elm app.
* Also saves the path of the loaded file for subsequent saving.
*/
function openFile() {
  const dialogOptions = {
    title: "Load Input File",
    properties: ['openFile']
  };

  dialog.showOpenDialog(dialogOptions, filenames => {
    if(typeof(filenames) === "undefined")
      return;
    if(filenames.length > 1) {
      alert("Can only load one file!")
    } else {
      currentFile = filenames[0];
      fs.readFile(currentFile, (err, data) => {
        app.ports.fileData.send(data.toString());
      });
    }
  });
}

app.ports.requestFile.subscribe(function() {
  openFile();
});

app.ports.createWindow.subscribe(function() {
  ipcRenderer.send('new-window');
});

/*
* Saves the file, if currentFile has not be set because I file has not be opened (this is a new document)
* then request a path from the user. An subsequent saves will be to that new file.
*/
function saveFile(text) {
  if(currentFile === "") {
    dialog.showSaveDialog({}, path => {
      currentFile = path;
      fs.writeFile(currentFile, text);
    });
  } else {
    fs.writeFile(currentFile, text);
  }

}

app.ports.writeToFile.subscribe(function(text) {
  saveFile(text);
});

// as part of an Editor window init, an index will be generated for associating its presentation window
ipcRenderer.once("window-pair-index", (event, newWindowIndex) => {
  windowIndex = newWindowIndex;
});

ipcRenderer.on("present", _ => {
  app.ports.present.send(null);
});

ipcRenderer.on("open", _ => {
  openFile();
});

ipcRenderer.on("save", _ => {
  app.ports.saveFile.send(null);
});
