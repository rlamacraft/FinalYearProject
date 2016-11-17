'use strict'
const electron = require('electron')
const {ipcMain} = require('electron');

const app = electron.app; // this is our app
const BrowserWindow = electron.BrowserWindow; // This is a Module that creates windows

let mainWindow; // saves a global reference to mainWindow so it doesn't get garbage collected
let presWindow; // this is the presentation window

app.on('ready', _ => {
  mainWindow = createWindow("editor", {
    width: 500,
    height: 600,
    show: true
  });
  presWindow = createWindow("presenter", {
    width: 800,
    height: 600,
    show: false
  });
}) // called when electron has initialized

// This will create our app window, no surprise there
function createWindow (htmlFilename, options) {
  const newWindow = new BrowserWindow(options)

  // display the index.html file
  newWindow.loadURL(`file://${ __dirname }/${ htmlFilename }.html`)

  // open dev tools by default so we can see any console errors
  newWindow.webContents.openDevTools()

  newWindow.on('closed', function () {
    mainWindow = null
  });

  return newWindow;
}

ipcMain.on('show-pres', function(event, message){
  presWindow.show();
  presWindow.webContents.send("show-pres", message);
});

/* Mac Specific things */

// when you close all the windows on a non-mac OS it quits the app
app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') { app.quit() }
})

// if there is no mainWindow it creates one (like when you click the dock icon)
app.on('activate', () => {
  if (mainWindow === null) { createWindow() }
})
