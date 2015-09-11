# synchronize resource operation
# author: ran <abbshr@outlook.com>

fs = require 'fs'
path = require 'path'

class Resource
  constructor: (options = {}) ->
    options.namespace ?= "default"
    options.dir ?= "/dev/shm"
    options.lockTimeout ?= 5000
    {@namespace, @dir, @lockTimeout} = options
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

    initLock()

  initLock: ->
    @lockdir = "#{@_ref}.lock"
    fs.mkdirSync @lockdir unless fs.existsSync @lockdir

  # 检查指定资源是否可以加锁(是否正在被其他进程使用)
  checkLocked: (key, flag) ->
    lockResource = "#{@lockdir}/#{key}"
    lockFile = "#{lockResource}/#{flag}.lock"
    fs.mkdirSync lockResource unless fs.existsSync lockResource

    count = fs.readdirSync lockResource
    locked = fs.existsSync lockFile

    if count > 0 and not locked
      err = new Error "lock request failed"
      err.name = "ResourceLocked"
    else
      null

  lockSync: (key, flag) ->
    ret = checkLocked key, flag
    unless ret?
      fs.writeFileSync lockFile, 1 unless locked
      # 设置锁的超时时间
      setTimeout =>
        @unlockSync key, flag
      , @lockTimeout
      null
    else
      ret

  unlockSync: (key, flag) ->
    lockResource = "#{@lockdir}/#{key}"
    lockFile = "#{lockResource}/#{flag}.lock"

    if fs.existsSync lockFile
      fs.unlinkSync lockFile
      null

  retrieveSync: (key, flag) ->
    ret = checkLocked key, flag
    return ret if ret?

    regstr = key
            .replace /[\+\-\^\$\?\.\{\}\[\]\|\,\(\)]/g, (o) -> "\\#{o}"
            .replace /\*/g, ".*"
    pattern = new RegExp "^#{regstr}$"

    ret = for entry in fs.readdirSync @_ref when pattern.test entry
      key: entry, value: fs.readFileSync "#{@_ref}/#{entry}"

    unlockSync key, flag
    ret

  deleteSync: (key, flag) ->
    ret = checkLocked key, flag
    return ret if ret?

    try
      # delete all
      unless key?
        @_clean @_ref
      else
        fs.unlinkSync "#{@_ref}/#{key}"
      unlockSync key, flag
    catch err
      err

  pushSync: (key, value, flag) ->
    ret = checkLocked key, flag
    return ret if ret?

    try
      fs.appendFileSync "#{@_ref}/#{key}", value
      unlockSync key, flag
    catch err
      err

  createSync: (key, value, flag) ->
    ret = checkLocked key, flag
    return ret if ret?

    try
      fs.writeFileSync "#{@_ref}/#{key}", value
      unlockSync key, flag
    catch err
      err

  cleanSync: (flag) ->
    ret = checkLocked key, flag
    return ret if ret?

    try
      @_clean @_ref
      unlockSync key, flag
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
