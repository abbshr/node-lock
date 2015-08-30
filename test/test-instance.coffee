fs = require 'fs'
path = require 'path'
should = require 'should'

Shm = require '../'

describe "Create Shm", () ->

  describe "in BSD", () ->
    context "when options is not provided", () ->
      it "should throw an Error: 'invalid shm path'", () ->
        (->
          new Shm
        ).should.throw 'invalid shm path'

    context "when options.dir is not provided", () ->
      it "should throw an Error: 'invalid shm path'", () ->
        (->
          new Shm namespace: "hydra"
        ).should.throw 'invalid shm path'


  describe "in Linux", () ->
    context "when options is not provided", () ->
      it "should not throw Error", () ->
        (->
          m = new Shm
        ).should.not.throw()
      it "namespace should be 'hydra'", () ->
        new Shm
        .namespace.should.equal "hydra"
      it "dir should be '/dev/shm'", () ->
        new Shm
        .dir.should.equal "/dev/shm"
      it "_ref should be '/dev/shm/hydra'", () ->
        new Shm
        ._ref.should.equal "/dev/shm/hydra"


  describe "when dir is provided", () ->
    context "if dir is a directory", () ->
      it "should not throw any error", () ->
        (->
          new Shm dir: path.join(__dirname, 'test-storage')
        ).should.not.throw()

      context "namespace is not existed", () ->
        it "namespace will be created", () ->
          m = new Shm dir: path.join(__dirname, 'test-storage')
          fs.existsSync m._ref
          .should.be.ok()

      context "namespace exist", () ->
        context "namespace is a directory", () ->
          it "should not throw Error", () ->
            (->
              m = new Shm dir: path.join(__dirname, 'test-storage'), namespace: 'existed-namespace'
            ).should.not.throw()

        context "namespace is not a directory", () ->
          it "should throw an Error", () ->
            (->
              new Shm path.join(__dirname, 'test-storage'), namespace: 'existed-namespace-file'
            ).should.throw()

    context "when dir is not a directory", () ->
      it "should throw an Error: 'invalid shm path'", () ->
        (->
          new Shm dir: path.join(__dirname, 'test-file')
        ).should.throw 'invalid shm path'

    context 'when the specified dir is not existed', () ->
      it "should throw an Error: 'invalid shm path'", () ->
        (->
          new Shm dir: path.join(__dirname, 'non-exist-dir')
        ).should.throw 'invalid shm path'
