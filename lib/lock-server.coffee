# author: ran <abbshr@outlook.com>
path = require 'path'
fs = require 'fs'
net = require 'net'
{log} = require 'util'
Resource = require './core'
Parser = require './parser'

server = null

class LockServer extends Parser

  constructor: (options) ->
    @_resource = new Resource options
    @_server = null
    @_lockTimeout = 800
    @sock = path.join '/tmp', "#{@_resource.dir}/#{@_resource.namespace}".replace /\//g, '-'
    @init()
    super()

  init: ->
    process.on 'exit', =>
      @close()

    if fs.existsSync @sock
      try
        fs.unlinkSync @sock
      catch err
        log err.toString()
        process.exit()

  startStandAlone: () ->
    @_server ?= net.createServer (socket) =>
      @parse socket, (raw) =>
        packet = raw.toString 'utf-8'
        @packetParser socket, packet
    .listen @sock, () =>
      log "Lock proxy server start listenning at #{@sock}"

  packetParser: (socket, packet) ->
    [command, args...] = packet.split '\n'
    ret = @exec command, args

    if ret instanceof Error
      if ret.name is 'ResourceLocked'
        setImmediate =>
          # 如果资源被上锁, 在next tick里重试
          @packetParser socket, packet
      else
        @response socket, @pack 'error', JSON.stringify ret
    else if ret?
      @response socket, @pack command, JSON.stringify ret
    else
      @response socket, @pack command, ''

  exec: (command, args) ->
    @_resource["#{command}Sync"]? args...

  response: (socket, packet) ->
    socket.write packet

  close: (callback = ->) ->
    @_server?.close callback

module.exports = (options) ->
  server ?= new LockServer options
