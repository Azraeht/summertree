# Springseed. Simply awesome note taking.
# Copyright (c) 2014, Springseed Team
# All Rights Reserved.

app 			= require "app"
Menu						= require "menu"
BrowserWindow 	= require "browser-window"
AboutWindow		 = require "./AboutWindow"

class SpringseedWindow
	constructor: (devtools) ->
		@window = new BrowserWindow
			'width': 1024
			'height': 600
			'min-width': 500
			'min-height': 300
			'center': true
			'title': "Springseed"
			'frame': false

		console.log __dirname

		@window.loadUrl "file://"+__dirname+"/../public/index.html"

		@window.on "closed",  ->
			@window = null # Dereference the window.

		if process.platform is "darwin"
			@osxMenus()
		else
			@linuxMenus()

	osxMenus: ->
		tmpl = [{
				label: "Springseed",
				submenu: [{
					label: "About Springseed",
					click: ->
						new AboutWindow()
					}, {
					label: "Quit",
					accelerator: "Command+Q",
					click: ->
						app.quit()
			}]
		}]

		menu = Menu.buildFromTemplate tmpl
		Menu.setApplicationMenu menu

	linuxMenus: ->
		# GNOME stuff.
		tmpl = [{
				label: "Application",
				submenu: [{
					label: "About Springseed",
					click: ->
						new AboutWindow()
					}, {
					label: "Quit",
					accelerator: "Command+Q",
					click: ->
						app.quit()
			}]
		}]

		menu = Menu.buildFromTemplate tmpl
		Menu.setMenu menu

module.exports = SpringseedWindow
