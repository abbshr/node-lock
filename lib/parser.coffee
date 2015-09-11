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
  #    row n     #
  ################
  #     \r\n     #
  ################

{EventEmitter} = require 'events'

class Parser extends EventEmitter

  OPEN: -1
  COLLECTING: 0
  DONE: 1

  constructor: () ->
    @emit 'init'

  parse: (readableStream, next = ->) ->
    state = Parser::OPEN
    packet = []

    reset = =>
      state = Parser::OPEN
      packet = []

    done = (packet) =>
      state = Parser::DONE
      @emit 'done', packet
      next new Buffer packet

    readableStream.on 'data', (chunk) =>
      for byte in chunk
        switch state
          when Parser::OPEN
            # '\r'
            if byte is 0x0d
              state = Parser::COLLECTING
            else
              packet.push byte
          when Parser::COLLECTING
            # '\n'
            if byte is 0x0a
              done packet
              reset()
            else
              packet.push 0x0d
              unless byte is 0x0d
                state = Parser::OPEN
                packet.push byte
          when Parser::DONE
            reset()

  pack: (args...) ->
    packet = "#{args.join '\n'}\r\n"
    new Buffer packet, 'utf-8'

module.exports = Parser
