# Summertree

**Current version: 2.0**

Summertree is the simple and easy way to take your notes.

# Binaries

Not enable yet

## Building this code

Summertree is based on the awesome work of the people at GitHub and as
such we use the fantastic `electron` framework to get stuff done. We have
introduced a new build system based on the GNU Makefile build system. Should the
build below fail, you should run `make clean` before trying again because some
make operations won't complete if they've errored. Nothing we can do to fix
this.

Guard is used to watch every modification on sources files and launch make each time
Summertree is written in CoffeeScript and uses Spine.JS for MVC.

For web version of summertree, use 'cake'

### Install

    sudo apt-get install nodejs npm
    sudo gem install sass
    git submodule update --init
    make npm

### Development

    bundle exec guard

### Build

    make clean
    make all

    cake build
    cake minify
    cake style

### Start

    make start

    cake server


If you're feeling awesome, you should contribute either with code.

## Official website

Not enable yet
