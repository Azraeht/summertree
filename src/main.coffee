# Summertree
# Copyright (c) 2015, Brice SANTUS
# All Rights Reserved.

app = require "app"
SummertreeWindow = require './Summertree'

app.on 'ready', ->
  window = new SummertreeWindow()

app.on 'window-all-closed', ->
  app.quit()

app.on 'activate-with-no-open-windows', ->
  window = new SummertreeWindow()
