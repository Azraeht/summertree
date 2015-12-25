# File with the make command
node_bin = ./node_modules/.bin

spsd = app/init.coffee
# atom : all sources files *.coffee
atom = $(wildcard src/*.coffee)
css = css/new.scss

spsd_out = public/application.js
# list of out-files coffe to js
atom_out = $(atom:%.coffee=%.js)
# css out file
css_out = public/application.css
# handelbars out file
handelbars_out = $(wildcard app/views/*.js)

all: npm build-atom handlebars style build-app

# convert coffeefile to jsfiles
build-atom: $(atom_out)

src/%.js: src/%.coffee
	@echo "Coffeeing ... $<"
	@$(node_bin)/coffee -bc $<

# Building App
build-app: $(spsd_out)

$(spsd_out): $(spsd)
	@echo "Browerifying/Coffeeing ... $<"
	@$(node_bin)/browserify -t coffeeify $< > $@

handlebars:
	@echo "Handlebars ... note and notebook"
	@$(node_bin)/handlebars app/views/note.handlebars -f app/views/note.js
	@$(node_bin)/handlebars app/views/notebook.handlebars -f app/views/notebook.js

# Conferting css sources files to out_css (with sass)
style:
	@sass $(css) $(css_out)

# install dependencies
npm:
		@npm install .

# cleaning project
clean:
	@rm -f $(spsd_out) $(atom_out) $(css_out) $(handelbars_out)

# start project
start:
	@npm start
