# node-shm
# author: ran

fs = require 'fs'
path = require 'path'
async = require 'async'
{isFunction} = require 'util'
{EventEmitter} = require 'events'

class Shm extends EventEmitter
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

  # mount: (callback = ->) ->
  #   @_init (err) =>
  #     if err?
  #       callback err
  #       process.nextTick () =>
  #         @emit 'error', err
  #     else
  #       try
  #         @_clean @_ref if fs.existsSync @_ref
  #       catch err
  #         callback err
  #         return process.nextTick () =>
  #           @emit 'error', err
  #       fs.mkdir @_ref, (err) =>
  #         if err?
  #           callback err
  #           @emit 'error', err
  #         else
  #           callback null
  #           @emit 'mounted'
  #   this
  # need 4 osx
  # detach: (callback = ->) ->
  #   if @_isDarwin
  #     if @_disk?
  #       spawn './utils/detach.sh', [@_disk, "-force"]
  #       @_disk = null
  #       callback null
  #       process.nextTick () =>
  #         @emit 'umounted'
  #     else
  #       err = new Error 'not attached'
  #       callback err
  #       process.nextTick () =>
  #         @emit 'error', err
  #   else
  #     callback null
  #     process.nextTick () =>
  #       @emit 'umounted'
  #   this

  retrieve: (key, callback = ->) ->
    regstr = key
            .replace /[\+\-\^\$\?\.\{\}\[\]\|\,\(\)]/g, (o) -> "\\#{o}"
            .replace /\*/g, ".*"
    pattern = new RegExp "^#{regstr}$"

    fs.readdir @_ref, (err, dirs) =>
      if err?
        callback err
        @emit "error", err
      else
        q = for entry in dirs when pattern.test entry
          do (entry) =>
            (callback) =>
              fs.readFile "#{@_ref}/#{entry}", (err, value) =>
                if err?
                  callback err
                  @emit 'error', err
                else
                  callback null, key: entry, value: value
        if q.length is 0
          err = new Error "key not exist"
          callback err
          @emit "error", err
        else
          async.parallel q, (err, ret) =>
            if err?
              callback err
              @emit "error", err
            else
              callback null, ret
              @emit 'end', ret
      this

    # fs.readFile "#{@_ref}/#{key}", (err, value) =>
    #   if err?
    #     callback err
    #     @emit 'error', err
    #   else
    #     callback null, value
    #     @emit 'end', value
    # this

  delete: (key, callback = ->) ->
    # delete all
    if not key? or isFunction key
      callback = key if key?
      @_clean @_ref
      process.nextTick () =>
        @emit 'deleted'
    else
      fs.unlink "#{@_ref}/#{key}", (err) =>
        if err?
          callback err
          @emit 'error', err
        else
          callback null
          @emit 'deleted'
    this

  push: (key, value, callback = ->) ->
    fs.appendFile "#{@_ref}/#{key}", value, (err) =>
      if err?
        callback err
        @emit 'error', err
      else
        callback null
        @emit 'finished'
    this

  create: (key, value, callback = ->) ->
    fs.writeFile "#{@_ref}/#{key}", value, (err) =>
      if err?
        callback err
        @emit 'error', err
      else
        callback null
        @emit 'created'
    this

  clean: () ->
    @_clean @_ref

  # _init: (callback) ->
  #   unless fs.existsSync @_path
  #     if @_isDarwin
  #       # hack on OSX
  #       spawn "./utils/create-disk.sh"
  #       .on 'close', (code) =>
  #
  #         spawn "./utils/mount.sh", ["shm", @_disk]
  #         .on 'close', (code) =>
  #           @_path = '/Volumes/shm'
  #           @_ref = path.join @_path, @dir
  #           callback null
  #         .stdout.on 'data', (d) ->
  #           console.log d.toString()
  #
  #       .stdout.on 'data', (d) =>
  #         @_disk = d.toString().trim()
  #     else
  #       throw new Error "Can not found /dev/shm"
  #   else
  #     @_ref = path.join @_path, @dir
  #     callback null


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
