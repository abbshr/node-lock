fs = require 'fs'
path = require 'path'
should = require 'should'

Shm = require '..'

describe "#create", () ->
  context "when callback is provided", () ->
    it "callback should be called", (done) ->
      m = new Shm dir: path.join(__dirname, './test-storage')
      .create 'k', 'v', (err) ->
        should.exist 'create'
        done()

  context "when 'created' event listener was added", () ->
    it "should emit 'created' event", (done) ->
      m = new Shm dir: path.join(__dirname, './test-storage')
      .create 'k', 'v'
      .on 'created', () ->
        should.exist 'create'
        done()

  it "should be override the old value", (done) ->
    m = new Shm dir: path.join(__dirname, './test-storage')
    .create 'k', 'v', (err) ->
      m.retrieve 'k', (err, v) ->
        m.create 'k', 'vv', (err) ->
          m.retrieve 'k'
          .on 'end', (d) ->
            d.toString().should.equal 'vv'
            done()
