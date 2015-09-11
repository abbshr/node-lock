Client = require '../lib/client'

client = new Client '/tmp/-tmp-default'

client.connect()
.then () ->
  client
  .once 'lock', ->
    client
    .on 'retrieve', (ret) ->
      console.log ret
      client.unlock 'key'
    .once 'create', () ->
      console.log 'created'
      client.retrieve 'key*'
    .create 'key', 'value'
  .lock 'key'
