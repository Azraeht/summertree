# Summertree
# Copyright (c) 2015, Brice SANTUS
# All Rights Reserved.

app = require "app"
Menu = require "menu"
BrowserWindow = require "browser-window"
AboutWindow = require "./AboutWindow"
SearchWindow = require "./SearchWindow"

# We need a global reference of the window because Node.js may GC if if we don't.
window = null

class SummertreeWindow
  constructor: ->
    window = new BrowserWindow
      'width': 1024
      'height': 600
      'min-width': 500
      'min-height': 300
      'center': true
      'title': "Summertree"

    console.log __dirname

    window.loadURL "file://"+__dirname+"/../public/index.html"

    window.on "closed",  ->
      window = null # Dereference the window.

    if process.platform is "darwin"
      @osxMenus()
    else
      @linuxMenus()

  osxMenus: ->
    tmpl = [{
        label: "Summertree",
        submenu: [{
          label: "Developer Tools",
          accelerator: "Control+Alt+I"
          click: =>
            window.openDevTools()
          }, {
          label: "About Summertree",
          click: =>
            new AboutWindow()
          }, {
          label: "Quit",
          accelerator: "Command+Q",
          click: =>
            app.quit()
      }]
    }]
  linuxMenus: ->
    tmpl = [{
        label: "Summertree",
        submenu: [{
          label: "Developer Tools",
          accelerator: "Control+Alt+I"
          click: =>
            window.openDevTools()
          }, {
          label: "About Summertree",
          click: =>
            new AboutWindow()
          }, {
          label: "Quit",
          accelerator: "Ctrl+Q",
          click: =>
            app.quit()
      }]
    }]

    menu = Menu.buildFromTemplate tmpl
    Menu.setApplicationMenu menu

module.exports = SummertreeWindow
