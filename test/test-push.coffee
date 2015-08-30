fs = require 'fs'
path = require 'path'
should = require 'should'

Shm = require '..'

describe "#push", () ->
  context "when callback is provided", () ->
    it "callback should be called", (done) ->
      m = new Shm dir: path.join(__dirname, 'test-storage')
      m.push 'k2', 'v2', (err) ->
        should.not.exist err
        done()

  context "when 'finished' event listener was added", () ->
    it "should emit 'finished' event", (done) ->
      m = new Shm dir: path.join(__dirname, 'test-storage')
      m.push 'k', 'v'
      .on 'finished', () ->
        should.exist 'push'
        done()

  it "should append new valud to old value", (done) ->
    m = new Shm dir: path.join(__dirname, 'test-storage')
    m.push 'k', 'v'
    .once 'finished', () ->
      m.retrieve 'k'
      .once 'end', (v) ->
        m.push 'k', 'v1'
        .once 'finished', () ->
          m.retrieve 'k', (err, d) ->
            d.toString().should.equal "#{v.toString()}v1"
            done()
