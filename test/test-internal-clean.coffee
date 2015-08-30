fs = require 'fs'
path = require 'path'
should = require 'should'

Shm = require '../'

describe "(internel) #_clean", () ->
  context "when not providing argument force (means with no)", () ->
    it "should clean the the children of tatget folder", () ->
      Shm::_clean path.join __dirname, './test-clean-folder'
      fs.readdirSync path.join __dirname, './test-clean-folder'
      .should.be.empty()

  context "when providing argument force with yes", () ->

    after () ->
      fs.mkdirSync path.join __dirname, './test-clean-folder'

    it "should remove the target folder", () ->
      Shm::_clean path.join(__dirname, './test-clean-folder'), yes
      fs.existsSync path.join __dirname, './test-clean-folder'
      .should.be.false()


  context "when argument entry stands for the folder which is not existed", () ->
    it "should emit 'error' event", (done) ->
      new Shm dir: path.join(__dirname, './test-storage')
      .on 'error', (err) ->
        should.exist err
        done()
      ._clean path.join __dirname, './test-clean-folder-non-exist'
