# Summertree
# Copyright (c) 2015, Brice SANTUS
# All Rights Reserved.

app = require "app"
BrowserWindow = require "browser-window"

class SearchWindow
  constructor: (devtools) ->
    @window = new BrowserWindow
      'width': 150
      'height': 50
      'resizable': false
      'title': "Search"

    @window.loadURL "file://#{__dirname}/../public/search.html"

    @window.on "closed",  ->
      @window = null # Dereference the window.

module.exports = SearchWindow
