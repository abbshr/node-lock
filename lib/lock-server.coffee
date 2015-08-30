# author: ran <abbshr@outlook.com>
path = require 'path'
net = require 'net'
M = require './shm'
Parser = require './parser'

server = null

class LockServer extends Parser

  constructor: (options) ->
    @_m = new M options
    @_server = null
    @init()
    super()

  init: ->
    process.on 'exit', =>
      @close()

  startStandAlone: () ->
    @_server ?= net.createServer (socket) =>
      socket
      .on 'readable', () =>
        @parse socket, (raw) =>
          packet = raw.toString 'utf-8'
          @response socket, @packetParser packet
    .listen path.join '/tmp', "#{@_m.dir}/#{@_m.namespace}".replace /\//g, '-'

  packetParser: (packet) ->
    [command, args...] = packet.split '\n'
    @pack command, exec command, args

  exec: (command, args) ->
    @_m["#{command}Sync"] args...

  response: (socket, packet) ->
    socket.write packet

  close: (callback = ->) ->
    @_server.close callback

module.exports = (options) ->
  server ?= LockServer options
