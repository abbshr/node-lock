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
        @response socket, @packetParser packet
    .listen @sock, () =>
      log "Lock proxy server start listenning at #{@sock}"

  packetParser: (packet) ->
    [command, args...] = packet.split '\n'
    ret = @exec command, args

    if ret instanceof Error
      @pack 'error', JSON.stringify ret
    else if ret?
      @pack command, JSON.stringify ret
    else
      @pack command, ''

  exec: (command, args) ->
    @_resource["#{command}Sync"]? args...

  response: (socket, packet) ->
    socket.write packet

  close: (callback = ->) ->
    @_server?.close callback

module.exports = (options) ->
  server ?= new LockServer options
