'use strict'
const Elm = require('./editor_elm.js');
const parser  = require('./parser.js');
const {ipcRenderer} = require('electron');

let container = document.getElementById('container');
let app = Elm.Editor.embed(container);

app.ports.parseText.subscribe(function(text) {
    ipcRenderer.send('show-pres', text);
});
