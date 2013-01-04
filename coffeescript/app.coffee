# Node Webkit Stuff
try
	gui = require 'nw.gui'
	fs = require 'fs'
	path = require 'path'
	ncp = require('ncp').ncp

	# OS Detection
	OSName = "Unknown OS"
	OSName = "Windows"  unless navigator.appVersion.indexOf("Win") is -1
	OSName = "Mac"  unless navigator.appVersion.indexOf("Mac") is -1
	OSName = "UNIX"  unless navigator.appVersion.indexOf("X11") is -1
	OSName = "Linux"  unless navigator.appVersion.indexOf("Linux") is -1

	node = true
	home_dir = process.env.HOME

	# Set Up Storage Stuffs
	if OSName is "Mac"
		storage_dir = path.join(home_dir, "/Library/Application Support/Noted/")
	if OSName is "Windows"
		#Microsoft y u so inconsistant? - Don't assume /AppData - XP uses /Application Data - Use ENV variable
		storage_dir = path.join(process.env.LOCALAPPDATA, "/Noted")
	if OSName is "Linux"
		storage_dir = path.join(home_dir, "/.config/Noted/")


# Proper Functions
window.noted =

	selectedList: "Getting Started"
	selectedNote: ""

	setupPanel: ->
		win = gui.Window.get()
		win.show()
		win.showDevTools()

		# Panel Controls
		$('#close').click ->
			win.close()
		$('#minimize').click ->
			win.minimize()
		$('#maximize').click ->
			win.maximize()

		# Panel Dragging
		$('#panel').mouseenter ->
			$('#panel').addClass('drag')
		$('#panel #decor img, #panel #noteControls img, #panel #search').mouseenter ->
			$('#panel').removeClass('drag')
		$('#panel #decor img, #panel #noteControls img, #panel #search').mouseleave ->
			$('#panel').addClass('drag')
		$('#panel').mouseleave ->
			$('#panel').removeClass('drag')

	setupUI: ->
		# Event Handlers
		$("#content header .edit").click ->

			# There should be a better way to do this
			if $(this).text() is "save"
				$(this).text "edit"
				$('.headerwrap .left h1').attr('contenteditable', 'false')
				fs.rename(path.join(storage_dir, "Notebooks", window.noted.selectedList, window.noted.selectedNote + '.txt'), path.join(storage_dir, "Notebooks", window.noted.selectedList, $('.headerwrap .left h1').html() + '.txt'))
				window.noted.selectedNote = $('.headerwrap .left h1').html()
				# Reload Notes.
				window.noted.loadNotes(window.noted.selectedList)
				window.noted.editor.preview()
			else
				$(this).text "save"
				$('.headerwrap .left h1').attr('contenteditable', 'true')
				window.noted.editor.edit()

		# Notebooks Click
		$("body").on "click", "#notebooks li", ->
			$(this).parent().find(".selected").removeClass "selected"
			$(this).addClass "selected"
			window.noted.loadNotes($(this).html())

		# Notes Click
		$("body").on "click", "#notes li", ->
			# UI
			$("#notes .selected").removeClass("selected")
			$(this).addClass("selected")

			# Loads Actual Note
			window.noted.loadNote($(this).find("h2").html())

		# Create Markdown Editor
		window.noted.editor = new EpicEditor
			container: 'contentbody'
			theme:
				base:'/themes/base/epiceditor.css'
				preview:'/themes/preview/style.css'
				editor:'/themes/editor/style.css'

		window.noted.editor.load()

	# We'll add more to this as stuff changes
	render: ->
		# Lists the New Notebooks & Shows Selected
		fs.readdir path.join(storage_dir, "Notebooks"), (err, data) ->
			window.noted.listNotebooks data



	listNotebooks: (data) ->
		i = 0
		while i < data.length
			if fs.statSync(path.join(storage_dir, "Notebooks", data[i])).isDirectory()
				$("#notebooks ul").append "<li data-id='" + data[i] + "'>" + data[i] + "</li>"

			# if i is data.length -1
			# 	if window.noted.selectedNote is ""
			# 		# We load the first Note
			# 		$($("#notes li")[0]).trigger "click"
			# 	else
			# 		$("#notes [data-id='" + window.noted.selectedNote + "']").trigger "click"
			i++

		# Add Selected Class to the Right Notebook
		$("#notebooks [data-id='" + window.noted.selectedList + "']").addClass("selected").trigger("click")

	loadNotes: (name) ->
		# Clear list while we load.
		$("#notes header h1").html(name)
		$("#notes ul").html("")
		fs.readdir path.join(storage_dir, "Notebooks", name), (err, data) ->
			i = 0
			while i < data.length

				# Makes sure that it is a text file
				if data[i].substr(data[i].length - 4, data[i].length) is ".txt"
					# Removes txt extension
					name = data[i].substr(0, data[i].length - 4)
					$("#notes ul").append "<li data-id='" + name + "'><h2>" + name + "</h2><time></time></li>"
				i++

	loadNote: (name) ->
		# Caches Selected Note
		window.noted.selectedNote = name

		# Opens ze note
		fs.readFile path.join(storage_dir, "Notebooks", window.noted.selectedList, name + '.txt'), 'utf-8', (err, data) ->
			throw err if (err)
			$('.headerwrap .left h1').html(name)
			window.noted.editor.importFile('file', data)
			window.noted.editor.preview()

# Document Ready Guff
$ ->

	if node
		window.noted.setupPanel()

	window.noted.setupUI()

	if node

		# If the notebooks file isn't made, we'll make some sample notes
		fs.readdir path.join(storage_dir, "/Notebooks/"), (err, data) ->
			if err
				if err.code is "ENOENT"
					fs.mkdir path.join(storage_dir, "/Notebooks/"), ->
						# Copy over the default notes & render
						ncp path.join(window.location.pathname, "../default_notebooks"), path.join(storage_dir, "/Notebooks/"), (err) ->
							window.noted.render()
			else
				window.noted.render()
