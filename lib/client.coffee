# author: ran <abbshr@outlook.com>
net = require 'net'
Parser = require './parser'

class ShmClient extends Parser

  constructor: (sock) ->
    @sock ?= '/tmp/-dev-shm-default'
    super()
    @init()

  init: ->
    @on 'done', (raw) =>
      [command, args...] = raw.toString('utf-8').split '\n'
      process.nextTick =>
        @emit command, args...

  connect: () ->
    @client ?= net.connect sock
    @cache ?= new Promise (resolve, reject) =>
      @client
      .on 'connect', () =>
        resolve @client
      .on 'error', (err) ->
        reject err
      .on 'close', (err) ->
        reject err
      .on 'readable', () =>
        @parse @client

  _sendPacket: (packet) ->
    @client.write packet

  retrieve: (key) ->
    packet = @pack 'retrieve', key
    @_sendPacket packet
    this

  delete: (key) ->
    packet = @pack 'delete', key
    @_sendPacket packet
    this

  push: (key, value) ->
    packet = @pack 'push', key, value
    @_sendPacket packet
    this

  create: (key, value) ->
    packet = @pack 'create', key, value
    @_sendPacket packet
    this

  clean: () ->
    packet = @pack 'clean'
    @_sendPacket packet
    this

module.exports = ShmClient
