# author: ran <abbshr@outlook.com>
net = require 'net'
Parser = require './parser'

class LockClient extends Parser

  constructor: (@sock = '/tmp/-dev-shm-default') ->
    super()
    @init()

  init: ->
    @on 'done', (raw) =>
      [command, args...] = raw.toString('utf-8').split '\n'
      process.nextTick =>
        @emit command, args...

  connect: () ->
    @client ?= net.connect @sock
    @cache ?= new Promise (resolve, reject) =>
      @client
        .on 'connect', () =>
          resolve @client
        .on 'error', (err) ->
          reject err
        .on 'close', (err) ->
          reject err
      @parse @client, (raw) =>
        @_packetParser raw

  _packetParser: (packet) ->
    splitIndex = packet.indexOf 0x0a
    event = packet[0...splitIndex].toString 'utf-8'
    data = packet[splitIndex + 1 ...].toString 'utf-8'

    console.log event, data
    if event is 'error'
      @emit event, new Error JSON.parse data
    else if data?.length
      @emit event, @_dataParser data
    else
      @emit event

  _dataParser: (data) ->
    for entry in JSON.parse data
      {key, value} = entry
      value = new Buffer value
      {key, value}

  _sendPacket: (packet) ->
    @client.write packet

  retrieve: (key) ->
    packet = @pack 'retrieve', key, process.pid
    @_sendPacket packet
    this

  delete: (key) ->
    packet = @pack 'delete', key, process.pid
    @_sendPacket packet
    this

  push: (key, value) ->
    packet = @pack 'push', key, value, process.pid
    @_sendPacket packet
    this

  create: (key, value) ->
    packet = @pack 'create', key, value, process.pid
    @_sendPacket packet
    this

  clean: () ->
    packet = @pack 'clean', process.pid
    @_sendPacket packet
    this

  lock: (key) ->
    packet = @pack 'lock', key, process.pid
    @_sendPacket packet
    this

  unlock: (key) ->
    packet = @pack 'unlock', key, process.pid
    @_sendPacket packet
    this

module.exports = LockClient
