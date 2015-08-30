fs = require 'fs'
path = require 'path'
should = require 'should'

Shm = require '..'

describe '#retrieve', () ->
  context "when key provided is not existed", () ->
    it "should emit 'error' event", (done) ->
      new Shm dir: path.join(__dirname, './test-storage')
      .retrieve 'non-existed'
      .on 'error', (err) ->
        should.exist err
        done()

  context "when key provided is existed", () ->
    it "should emit 'end' event", (done) ->
      m = new Shm dir: path.join(__dirname, './test-storage')
      .create 'k', 'v'
      .on 'created', () ->
        m.retrieve 'k'
      .on 'end', (d) ->
        should.exist 'end'
        done()
