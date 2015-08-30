# A Fast Synchronize Parser
# author: ran <abbshr@outlook.com>
#
# Frame format:
  ################
  #    row 1\n   #
  ################
  #    row 2\n   #
  ################
  #    .....\n   #
  ################
  #    row n\n   #
  ################
  #     \r\n     #
  ################

{EventEmitter} = require 'events'

class Parser extends EventEmitter

  OPEN: -1
  COLLECTING: 0
  DONE: 1

  constructor: () ->
    @_packet = []
    @_lastChunk = null
    @state = Parser::OPEN
    @emit 'init'

  reset: () ->
    @state = Parser::OPEN
    @_packet = []
    @emit 'reset'

  parse: (src, next = ->) ->
    while chunk = src.read 1
      switch @state
        when Parser::OPEN
          # '\r'
          if chunk[0] is 0x0d
            @state = Parser::COLLECTING
            @_lastChunk = chunk
          else
            @_packet.push chunk
        when Parser::COLLECTING
          # '\n'
          if chunk[0] is 0x0a
            @state = Parser::DONE
          else
            @_packet.concat [@_lastChunk, chunk]
        when Parser::DONE
          next @_packet
          @emit 'done', @_packet
          @reset()

  pack: (args...) ->
    packet = "#{args.join '\n'}\r\n"
    new Buffer packet, 'utf-8'
