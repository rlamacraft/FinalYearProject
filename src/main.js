'use strict'
const electron = require('electron')
const {ipcMain} = require('electron');

const {app, Menu} = require('electron')
const BrowserWindow = electron.BrowserWindow; // This is a Module that creates windows

// all created presenter windows, object so that windows can be efficiently closed and reopened.
const windows = {
  "editorWindows": {},
  "presenterWindows": {}
}
let windowCount = 0;

const createEditorWindow = _ => {
  const newEditorWindow = createWindow("editor/index", {
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
  const newPresenterWindow = createWindow("presenter/index", {
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

function setApplicationMenu() {
  let menuTemplate = [
    {
      label: 'File',
      submenu: [
        {
          label: "New",
          accelerator: 'Command+N',
          click: _ => { createEditorWindow(); }
        },
        {
          label: "Open..." ,
          accelerator: 'Command+O',
          click: _ => { BrowserWindow.getFocusedWindow().webContents.send("open"); }
        },
        {
          label: "Save",
          accelerator: 'Command+S',
          click: _ => { BrowserWindow.getFocusedWindow().webContents.send("save"); }
        },
      ]
    },
    {
      label: "Edit",
      submenu: [
        {
          label: 'Undo',
          accelerator: 'Command+Z',
          selector: 'undo:'
        },
        {
          label: 'Redo',
          accelerator: 'Shift+Command+Z',
          selector: 'redo:'
        },
        {
          type: 'separator'
        },
        {
          label: 'Cut',
          accelerator: 'Command+X',
          selector: 'cut:'
        },
        {
          label: 'Copy',
          accelerator: 'Command+C',
          selector: 'copy:'
        },
        {
          label: 'Paste',
          accelerator: 'Command+V',
          selector: 'paste:'
        },
        {
          label: 'Select All',
          accelerator: 'Command+A',
          selector: 'selectAll:'
        }
      ]
    },
    {
      label: "View",
      submenu: [
        {
          label: "Present",
          accelerator: "Command+P",
          click: _ => { BrowserWindow.getFocusedWindow().webContents.send("present"); }
        },
        {
          label: "Dev Tools",
          accelerator: "Command+Alt+J",
          click: _ => { BrowserWindow.getFocusedWindow().webContents.openDevTools(); }
        }
      ]
    }
  ];
  const macOSMenu = {
    label: app.getName(),
    submenu: [
      { role: 'about' },
      { type: 'separator' },
      { role: 'services', submenu: [] },
      { type: 'separator' },
      { role: 'hide' },
      { role: 'hideothers' },
      { role: 'unhide' },
      { type: 'separator' },
      { role: 'quit' }
    ]
  };
  if(process.platform === 'darwin') {
    menuTemplate.unshift(macOSMenu);
    menuTemplate.push({label: "Window", submenu: [
      {
        label: 'Minimize',
        accelerator: 'Command+M',
        selector: 'performMiniaturize:'
      },
      {
        label: 'Close',
        accelerator: 'Command+W',
        selector: 'performClose:'
      },
      {
        type: 'separator'
      },
      {
        label: 'Bring All to Front',
        selector: 'arrangeInFront:'
      }
    ]});
  }
  Menu.setApplicationMenu(Menu.buildFromTemplate(menuTemplate));
  app.setName("Markup Presenter");
}

// Called when electron has initialized
app.on('ready', _ => {
  setApplicationMenu();
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
});

// when you click the dock icon, find the first valid editor window, else create one
app.on('activate', () => {
  const allEditorWindows = Object.keys(windows.editorWindows)
    .map(key => windows.editorWindows[key])
    .filter(window => !window.isDestroyed());
  if(allEditorWindows.length === 0) {
    createEditorWindow();
  } else {
    allEditorWindows[0].show();
  }
});
