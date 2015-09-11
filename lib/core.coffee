# synchronize resource operation
# author: ran <abbshr@outlook.com>

fs = require 'fs'
path = require 'path'

class Resource
  constructor: (options = {}) ->
    options.namespace ?= "default"
    options.dir ?= "/dev/shm"
    {@namespace, @dir} = options
    @init()

  init: ->
    if fs.existsSync(@dir) and fs.statSync(@dir).isDirectory()
      @_ref = path.join @dir, @namespace
      if fs.existsSync @_ref
        unless fs.statSync(@_ref).isDirectory()
          throw new Error "#{@_ref} is not a directory"
      else
        fs.mkdirSync @_ref
    else
      throw new Error "invalid resource path"

  retrieveSync: (key) ->
    regstr = key
            .replace /[\+\-\^\$\?\.\{\}\[\]\|\,\(\)]/g, (o) -> "\\#{o}"
            .replace /\*/g, ".*"
    pattern = new RegExp "^#{regstr}$"

    for entry in fs.readdirSync @_ref when pattern.test entry
      key: entry, value: fs.readFileSync "#{@_ref}/#{entry}"

  deleteSync: (key) ->
    try
      # delete all
      unless key?
        @_clean @_ref
      else
        fs.unlinkSync "#{@_ref}/#{key}"
    catch err
      err

  pushSync: (key, value) ->
    try
      fs.appendFileSync "#{@_ref}/#{key}", value
    catch err
      err

  createSync: (key, value) ->
    try
      fs.writeFileSync "#{@_ref}/#{key}", value
    catch err
      err

  cleanSync: () ->
    try
      @_clean @_ref
      null
    catch err
      err

  # sync mode
  _clean: (entry, force = no) ->
    if fs.statSync(entry).isFile()
      fs.unlinkSync entry
      console.log "=> rm #{entry}"
    else
      for item in fs.readdirSync entry when not item.match /^\.{1,2}$/
        @_clean path.join(entry, item), yes
      fs.rmdirSync entry if force

module.exports = Resource
