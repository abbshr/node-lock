Client = require '../lib/client'

client = new Client '/tmp/-tmp-default'

client.connect()
.then () ->
  client
  .on 'retrieve', (ret) ->
    console.log ret
    client.delete 'key'
  .once 'create', () ->
    console.log 'created'
    client.retrieve 'key*'
  .once 'delete', () ->
    console.log 'deleted'
  .once 'error', (err) ->
    console.log err
  .create 'key', 'value'
  .create 'key1', 'v1'
  .create 'ke2', 'v2'
