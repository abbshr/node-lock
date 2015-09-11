LockServer = require '../lib/lock-server'

server = LockServer dir: '/tmp'
server.startStandAlone()
