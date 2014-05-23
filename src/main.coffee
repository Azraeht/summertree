# Springseed. Simply awesome note taking.
# Copyright (c) 2014, Springseed Team
# All Rights Reserved.

app = require "app"
SpringseedWindow = require './springseed'

app.on 'ready', ->
  window = new SpringseedWindow()

app.on 'window-all-closed', ->
  if process.platform is not 'darwin'
    app.quit()
