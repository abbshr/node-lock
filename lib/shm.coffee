# node-shm
# author: ran <abbshr@outlook.com>

fs = require 'fs'
path = require 'path'

class Shm
  constructor: (options = {}) ->
    options.namespace ?= "default"
    options.dir ?= "/dev/shm"
    {@namespace, @dir} = options
    if fs.existsSync(@dir) and fs.statSync(@dir).isDirectory()
      @_ref = path.join @dir, @namespace
      if fs.existsSync @_ref
        unless fs.statSync(@_ref).isDirectory()
          throw new Error "#{@_ref} is not a directory"
      else
        fs.mkdirSync @_ref
      super()
    else
      throw new Error "invalid shm path"

  retrieveSync: (key) ->
    regstr = key
            .replace /[\+\-\^\$\?\.\{\}\[\]\|\,\(\)]/g, (o) -> "\\#{o}"
            .replace /\*/g, ".*"
    pattern = new RegExp "^#{regstr}$"

    for entry in fs.readdirSync @_ref when pattern.test entry
      key: entry, value: fs.readFileSync "#{@_ref}/#{entry}"

  deleteSync: (key) ->
    # delete all
    unless key?
      @_clean @_ref
    else
      fs.unlinkSync "#{@_ref}/#{key}"

  pushSync: (key, value) ->
    fs.appendFileSync "#{@_ref}/#{key}", value

  createSync: (key, value) ->
    fs.writeFileSync "#{@_ref}/#{key}", value

  cleanSync: () ->
    @_clean @_ref

  # sync mode
  _clean: (entry, force = no) ->
    try
      isFile = fs.statSync(entry).isFile()
    catch err
      return process.nextTick () =>
        @emit "error", err
    if isFile
      fs.unlinkSync entry
      console.log "=> rm #{entry}"
    else
      for item in fs.readdirSync entry when not item.match /^\.{1,2}$/
        @_clean path.join(entry, item), yes
      fs.rmdirSync entry if force

module.exports = Shm
