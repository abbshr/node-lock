fs = require 'fs'
path = require 'path'
should = require 'should'

Shm = require '../'

describe '#delete', () ->
  context "when key is provided", () ->
    it "should emit 'error' event if key is not existed", (done) ->
      new Shm dir: path.join(__dirname, './test-storage')
      .delete 'non-existed'
      .on 'error', (err) ->
        should.exist err
        done()

    it "should delete the key", (done) ->
      m = new Shm dir: path.join(__dirname, './test-storage')
      .create 'k', 'v'
      .once 'created', () ->
        m.delete 'k'
      .on 'deleted', () ->
        should.ok 'deleted'
        done()

  context "when key is not provided", () ->
    it "should deleted all the keys stored in namespace", (done) ->
      m = new Shm dir: path.join(__dirname, './test-storage')
      .create 'k1', 'v', (err) ->
        m.create 'k2', 'v', (err) ->
          m.create 'k3', 'v'
          .once 'created', () ->
            m.delete()
      .on 'deleted', () ->
        should.ok 'deleted'
        done()
