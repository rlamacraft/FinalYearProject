'use strict'
const electron = require('electron')
const {ipcMain} = require('electron');

const app = electron.app; // this is our app
const BrowserWindow = electron.BrowserWindow; // This is a Module that creates windows

// all created presenter windows, object so that windows can be efficiently closed and reopened.
const windows = {
  "editorWindows": {},
  "presenterWindows": {}
}
let windowCount = 0;

const createEditorWindow = _ => {
  const newEditorWindow = createWindow("editor", {
    width: 500,
    height: 600,
    show: false
  });
  newEditorWindow.once('ready-to-show', () => {
    newEditorWindow.webContents.send("window-pair-index", windowCount + "");
    windows.editorWindows[windowCount] = newEditorWindow;
    ++windowCount;
    newEditorWindow.show();
  });
  return newEditorWindow;
};
const createPresenterWindow = (windowsIndex, content) => {
  const newPresenterWindow = createWindow("presenter", {
    width: 800,
    height: 600,
    show: false
  });
  windows.presenterWindows[windowsIndex] = newPresenterWindow;
  newPresenterWindow.once('ready-to-show', () => {
    newPresenterWindow.webContents.send("show-pres", content);
    newPresenterWindow.show();
  });
  return newPresenterWindow
}

// Called when electron has initialized
app.on('ready', _ => {
  createEditorWindow();
});

// This will create our app window, no surprise there
function createWindow (htmlFilename, options) {
  const newWindow = new BrowserWindow(options)
  newWindow.loadURL(`file://${ __dirname }/${ htmlFilename }.html`)
  return newWindow;
}

// When the user chooses to present their document.
ipcMain.on('show-pres', (event, windowIndex, message) => {
  let presWindow = windows.presenterWindows[windowIndex];
  const updateContent = (content) => {
    presWindow.webContents.send("show-pres", content);
    presWindow.show();
  }
  if(typeof(presWindow) === "undefined" || presWindow.isDestroyed()) {
    presWindow = createPresenterWindow(windowIndex, message);
  } else {
    updateContent(message);
  }
});

ipcMain.on('new-window', () => {
  createEditorWindow();
})

/* Mac Specific things */

// when you close all the windows on a non-mac OS it quits the app
app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') { app.quit() }
})

// if there is no mainWindow it creates one (like when you click the dock icon)
app.on('activate', () => {
  if (mainWindow === null) { createEditorWindow() }
})
