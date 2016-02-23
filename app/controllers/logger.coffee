Spine = require 'spine'

# Models
Note = require '../models/note.coffee'
Notebook = require '../models/notebook.coffee'
Modal = require '../controllers/modal.coffee'
Settings = require '../controllers/settings.coffee'
Account = require '../controllers/account.coffee'

class Logger extends Spine.Controller
  constructor: ->
    super

  @log: (level, message) =>
    debuglevel = 'warn'
    levels = ['error', 'warn', 'info']
    if levels.indexOf level >= levels.indexOf debuglevel
      console.log(level + ' : ' + message)

  @debug: (message) =>
    this.log(message)


module.exports = Logger
