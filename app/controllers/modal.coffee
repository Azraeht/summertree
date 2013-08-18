Spine = require "spine"
$ = Spine.$

# Needed.
Note = require("../models/note.coffee")

# Base Modal Class.
class Modal extends Spine.Controller
  constructor: (opts) ->
    super

  state: off

  show: ->
    return unless @state is off
    @state = on
    @el.show(0).addClass("show")
    if @onShow then @onShow()
    setTimeout ( =>
      @el.on "click.modal", (event) =>
        if event.target.className.indexOf("modal") >= 0 then @hide()
    ), 500

  hide: ->
    return unless @state is on
    @state = off
    @el.removeClass("show")
    setTimeout ( =>
      @el.hide(0)
      if @onHide then @onHide()
    ), 350
    @el.off("click.modal")

modals = []

module.exports =

  get: (name) ->
    # Return a Modal object. Like a pro.
    return modals[name]

  init: ->
    # Do init stuff here.
    # Like, uh, getting modals sorted. Yolo.
    modals['delete'] = new Modal
      el: $('.modal.delete')
      events:
        'click .true': 'delete'
        'click .false': 'hide'
      
      run: ->
        @show()
      
      delete: ->
        # Taken from controllers/panel.coffee.
        if Note.current isnt undefined
          currentNote = Note.find(Note.current.id)

          # Take it out of editmode
          Note.trigger("changeNote")

          # Delete from indexeddb first
          currentNote.deleteNote()
          currentNote.destroy()

          @hide()

    