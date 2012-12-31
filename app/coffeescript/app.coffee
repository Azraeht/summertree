$ ->
	# Parse Initial Text
	#window.noted.parseText()

	# Event Handlers
	$("#content header .edit").click ->

		# There should be a better way to do this
		if $(this).text() is "save"
			$(this).text "edit"
			window.noted.editor.preview()
		else
			$(this).text "save"
			window.noted.editor.edit()


	window.noted.editor = new EpicEditor
		container: 'contentbody'
		theme:
    		base:'/themes/base/epiceditor.css'
    		preview:'/themes/preview/style.css'
		    editor:'/themes/editor/style.css'
	window.noted.editor.load()
	window.noted.editor.importFile('some-file',"#Imported markdown\nFancy, huh?")
	window.noted.editor.preview()

window.noted = {}
