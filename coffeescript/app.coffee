

# Node Webkit Stuff\
gui = global.gui 		= require 'nw.gui'
fs 			= require 'fs'
buffer 		= require 'buffer'
path 		= require 'path'
ncp 		= require('ncp').ncp
util 		= require 'util'
handlebars	= require 'handlebars'
global.document = document
Splitter = require './javascript/lib/splitter'

node = true
home_dir = process.env.HOME
reserved_chars = [	186,	# : ;
					191,	# / ?
					220,	# \ |
					222,	# ' "
					106,	# numpad *
					56 ]	# SHIFT-8 *

# Set Up Storage - are there env variables for these?
if process.platform is "darwin"
	storage_dir = path.join(home_dir, "/Library/Application Support/Noted/")
else if process.platform is "win32"
	storage_dir = path.join(process.env.LOCALAPPDATA, "/Noted")
else if process.platform is "linux"
	storage_dir = path.join(home_dir, "/.config/Noted/")

# Proper Functions
window.noted =

	selectedList: "all"
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
		$('#panel').mouseenter(->
			$('#panel').addClass('drag')
		).mouseleave ->
			$('#panel').removeClass('drag')

		# # Disallows Dragging on Buttons
		# $('#panel #decor img, #panel #noteControls img, #panel #search').mouseenter(->
		# 	$('#panel').removeClass('drag')
		# ).mouseleave ->
		# 	$('#panel').addClass('drag')

	setupUI: ->
		Splitter.init
			parent: $("#parent")[0],
			panels:
				left:
					el: $("#notebooks")[0]
					min: 150
					width: 200
					max: 450
				center:
					el: $("#notes")[0]
					min: 250
					width: 300
					max: 850
				right:
					el: $("#content")[0]
					min: 450
					width: 550
					max: Infinity

		# Event Handlers
		$("#content .edit").click window.noted.editMode

		# Notebooks Click
		$("body").on "click", "#notebooks li", ->
			$(@).parent().find(".selected").removeClass "selected"
			$(@).addClass "selected"
			window.noted.loadNotes($(@).text())
			window.noted.deselectNote()

		$("body").on "contextmenu", "#notebooks li", ->
			name = $(this).text()
			console.log name
			window.noted.editor.remove('file')
			fs.unlink path.join(storage_dir, "Notebooks", name, '*'), (err) ->
				fs.rmdir path.join(storage_dir, "Notebooks", name), (err) ->
					throw err if (err)
					window.noted.deselectNote()
					window.noted.listNotebooks()

		$('body').on "keydown", "#notebooks input", (e) ->
			# Deny the enter key
			name = $('#notebooks input').val()
			if e.keyCode is 13
				e.preventDefault()
				while fs.existsSync(path.join(storage_dir, "Notebooks", window.noted.selectedList, name+'.txt')) is true
					regexp = /\(\s*(\d+)\s*\)$/
					if regexp.exec(name) is null
						name = name+" (1)"
					else
						name = name.replace(" ("+regexp.exec(name)[1]+")", " ("+(parseInt(regexp.exec(name)[1])+1)+")")
				fs.mkdir(path.join(storage_dir, "Notebooks", name))

				window.noted.listNotebooks()
				$('#notebooks input').val("").blur()

		# Notes Click
		$("body").on "click", "#notes li", ->
			# UI
			@el = $(@)

			$("#notes .selected").removeClass("selected")
			@el.addClass("selected")

			# Loads Actual Note
			window.noted.loadNote(@el)

		# Because we can't prevent default on keyup
		$("body").on "keydown", ".headerwrap .left h1", (e) ->
			console.log e.keyCode
			# Deny the enter key
			if e.keyCode is 13
				e.preventDefault()
				name = $(@).text()
				while fs.existsSync(path.join(storage_dir, "Notebooks", window.noted.selectedList, name+'.txt')) is true
					regexp = /\(\s*(\d+)\s*\)$/
					if regexp.exec(name) is null
						name = name+" (1)"
					else
						name = name.replace(" ("+regexp.exec(name)[1]+")", " ("+(parseInt(regexp.exec(name)[1])+1)+")")

					fs.rename(
						path.join(
							storage_dir,
							"Notebooks",
							window.noted.selectedList,
							window.noted.selectedNote + '.txt'
						),
						path.join(
							storage_dir,
							"Notebooks",
							window.noted.selectedList,
							name + '.txt'
						)
					)
					window.noted.selectedNote = name;
				window.noted.loadNotes(window.noted.selectedList)
				$(@).blur()
			else if e.keyCode in reserved_chars
				e.preventDefault()

		$("body").on "keyup", ".headerwrap .left h1", (e) ->
			# We can't have "".txt
			name = $(@).text()
			name = name + "_" while fs.existsSync(path.join(storage_dir, "Notebooks", window.noted.selectedList, name+'.txt')) is true
			$("#notes [data-id='" + window.noted.selectedNote + "']")
				.attr("data-id", name).find("h2").text($(@).text())
			if $(@).text() isnt ""

				console.log "renaming note"

				console.log path.join(storage_dir,"Notebooks",window.noted.selectedList,window.noted.selectedNote + '.txt')
				console.log path.join(storage_dir,"Notebooks",window.noted.selectedList,$(@).text() + '.txt')

				# Renames the Note
				fs.rename(
					path.join(
						storage_dir,
						"Notebooks",
						window.noted.selectedList,
						window.noted.selectedNote + '.txt'
					),
					path.join(
						storage_dir,
						"Notebooks",
						window.noted.selectedList,
						name + '.txt'
					)
				)

				window.noted.selectedNote = name

		# Create Markdown Editor
		window.noted.editor = new EpicEditor
			container: 'contentbody'
			file:
				name: 'epiceditor',
				defaultContent: '',
				autoSave: 2500
			theme:
				base:'/themes/base/epiceditor.css'
				preview:'/themes/preview/style.css'
				editor:'/themes/editor/style.css'

		window.noted.editor.load()

		window.noted.editor.on "save", (e) ->
			list = $("#notes li[data-id='" + window.noted.selectedNote + "']").attr "data-list"
			# Make sure a note is selected
			if window.noted.selectedNote isnt ""
				# Check if there's actually a difference.
				notePath = path.join(
					storage_dir,
					"Notebooks",
					list,
					window.noted.selectedNote + '.txt'
				)

				# Write file if something actually got modified
				fs.writeFile(notePath, e.content) if e.content isnt fs.readFileSync(notePath).toString()

				# Reload to reveal new timestamp
				# TODO: window.noted.loadNotes(window.noted.selectedList)

		# Add note modal dialogue.
		$('#new').click ->
			name = "Untitled Note"
			if window.noted.selectedList isnt "All Notes" and window.noted.editor.eeState.edit is false
				while fs.existsSync(path.join(storage_dir, "Notebooks", window.noted.selectedList, name+'.txt')) is true
					regexp = /\(\s*(\d+)\s*\)$/
					if regexp.exec(name) is null
						name = name+" (1)"
					else
						name = name.replace(" ("+regexp.exec(name)[1]+")", " ("+(parseInt(regexp.exec(name)[1])+1)+")")
						console.log regexp.exec(name)[1]
				# Write file to disk
				fs.writeFile(
					path.join(
						storage_dir,
						"Notebooks",
						window.noted.selectedList, name + '.txt'
					),
					"Add some content!",
					->
						# Function in a Function. Functionception (this is a bad idea).
						window.noted.loadNotes window.noted.selectedList, "", ->
							console.log("hello")
							$("#notes ul li:first").addClass("edit").trigger "click"
				)

		$('#del').click ->
			$(".modal.delete").modal()

		$(".modal.delete .true").click ->
			$(".modal.delete").modal "hide"
			window.noted.editor.remove('file')
			if window.noted.selectedNote isnt ""
				fs.unlink(
					path.join(
						storage_dir,
						"Notebooks",
						$("#notes li[data-id='" + window.noted.selectedNote + "']").attr("data-list"),
						window.noted.selectedNote + '.txt'
					), (err) ->
						throw err if (err)
						window.noted.deselectNote()
						window.noted.loadNotes(window.noted.selectedList)
				)

		$(".modal.delete .false").click ->
			$(".modal.delete").modal "hide"

	editMode: (mode) ->
		el = $("#content .edit")
		if mode is "preview" or window.noted.editor.eeState.edit is true and mode isnt "editor"

			el.text "edit"
			$('#content .left h1').attr('contenteditable', 'false')
			$('#contentbody')

			window.noted.editor.save()
			window.noted.editor.preview()
		else
			el.text "save"
			$('.headerwrap .left h1').attr('contenteditable', 'true')
			window.noted.editor.edit()

	render: ->
		# Lists the New Notebooks & Shows Selected
		window.noted.listNotebooks()

	listNotebooks: ->
		# Yay! Templating
		template = handlebars.compile($("#notebook-template").html())
		htmlstr = template({name: "All Notes", class: "all"})

		fs.readdir path.join(storage_dir, "Notebooks"), (err, data) ->
			i = 0
			while i < data.length
				if fs.statSync(path.join(storage_dir, "Notebooks", data[i])).isDirectory()
					htmlstr += template({name: data[i]})
				i++

			# Append the string to the dom (perf matters.)
			$("#notebooks ul").html(htmlstr)
			$("#notebooks [data-id='" + window.noted.selectedList + "'], #notebooks ." + window.noted.selectedList).trigger("click")

	loadNotes: (list, type, callback) ->
		window.noted.selectedList = list

		# Templates :)
		template = handlebars.compile($("#note-template").html())
		htmlstr = ""

		if list is "All Notes"
			# There will be some proper code in here soon
			htmlstr = "I broke all notes because of the shitty implementation"
		else
			# It's easier doing @ without Async.
			data = fs.readdirSync path.join(storage_dir, "Notebooks", list)
			order = []
			i = 0

			while i < data.length
				# Makes sure that it is a text file
				if data[i].substr(data[i].length - 4, data[i].length) is ".txt"
					# Removes txt extension
					name = data[i].substr(0, data[i].length - 4)
					time = new Date fs.statSync(path.join(storage_dir, "Notebooks", list, name + '.txt'))['mtime']

					# Gets an excerpt
					fd = fs.openSync(path.join(storage_dir, "Notebooks", list, name + '.txt'), 'r')
					buffer = new Buffer(100)
					num = fs.readSync fd, buffer, 0, 100, 0
					info = $(marked(buffer.toString("utf-8", 0, num))).text()
					fs.close(fd)

					# Makes a pretty Excerpt
					if info.length > 90
						lastIndex = info.lastIndexOf(" ")
						info = info.substring(0, lastIndex) + "&hellip;"

					order.push {id: i, time: time, name: name, info: info}
				i++

			# Sorts all the notes by time
			order.sort (a, b) ->
				return new Date(a.time) - new Date(b.time)

			# Appends to DOM
			for note in order
				htmlstr = template({
					name: note.name
					list: list
					year: note.time.getFullYear()
					month: note.time.getMonth() + 1
					day: note.time.getDate()
					excerpt: note.info
					}) + htmlstr

		$("#notes ul").html(htmlstr)
		callback() if callback

	loadNote: (selector) ->

		# Caches Selected Note and List
		window.noted.selectedNote = $(selector).find("h2").text()

		# Opens ze note
		fs.readFile path.join(storage_dir, "Notebooks", $(selector).attr("data-list"), window.noted.selectedNote + '.txt'), 'utf-8', (err, data) ->
			throw err if (err)
			$("#content").removeClass("deselected")
			$('.headerwrap .left h1').text(window.noted.selectedNote)
			noteTime = fs.statSync(path.join(storage_dir, "Notebooks", $(selector).attr("data-list"), window.noted.selectedNote + '.txt'))['mtime']
			time = new Date(Date.parse(noteTime))
			$('.headerwrap .left time').text(window.noted.timeControls.pad(time.getFullYear())+"/"+(window.noted.timeControls.pad(time.getMonth()+1))+"/"+time.getDate()+" "+window.noted.timeControls.pad(time.getHours())+":"+window.noted.timeControls.pad(time.getMinutes()))
			# ^ This code is fucking shit. What were you thinking mh0?
			window.noted.editor.importFile('file', data)

			# Chucks it into the right mode - this was the best I could do.
			if selector.hasClass("edit")
				window.noted.editMode("editor")
				$("#content .left h1").focus()
				selector.removeClass("edit")
			else
				window.noted.editMode("preview")

	deselectNote: ->
		$("#content").addClass("deselected")
		$("#content .left h1, #content .left time").text("")
		window.noted.selectedNote = ""
		window.noted.editor.importFile('file', "")
		window.noted.editor.preview()

window.noted.timeControls =
	pad: (n) ->
		(if (n < 10) then ("0" + n) else n)

# Document Ready Guff
$ ->
	window.noted.setupUI()

	# Prevent I-Beam Cursor
	# $('#panel, #notebooks, #notes').mousedown (e) ->
	# 	if e.target.tagName isnt "INPUT"
	# 		$(@).css('cursor','default')
	# 		return false

	if node
		window.noted.setupPanel()

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
