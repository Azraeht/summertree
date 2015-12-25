# Summertree
# Copyright (c) 2015, Brice SANTUS
# All Rights Reserved.

app = require "app"
BrowserWindow = require "browser-window"

class AboutWindow
  constructor: (devtools) ->
    @window = new BrowserWindow
      'width': 400
      'height': 300
      'center': true
      'resizable': false
      'title': "About Summertree"

    @window.loadURL "file://#{__dirname}/../public/about.html"

    @window.on "closed",  ->
      @window = null # Dereference the window.

module.exports = AboutWindow
