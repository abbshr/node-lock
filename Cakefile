{spawn} = require 'child_process'
{isArray} = require 'util'

option "-c", "--case [CaseName]", "test case name"

cases = [
  "instance"
  "internal-clean"
  "create"
  "push"
  "retrieve"
  "delete"
]

task "test", "run test", (options) ->
  if options.case in cases
    run options.case
  else
    run cases for caseName in cases

run = (cases) ->
  if isArray cases
    if cases[0]?
      spawn 'mocha', ['--compilers', 'coffee:coffee-script/register', "test/test-#{cases[0]}.coffee"]
      .on 'close', () ->
        run cases[1..]
      .stdout.on 'data', (data) ->
        console.log data.toString()
    else
      process.exit 0
  else
    spawn 'mocha', ['--compilers', 'coffee:coffee-script/register', "test/test-#{cases}.coffee"]
    .on 'close', (code) ->
      process.exit code
    .stdout.on 'data', (data) ->
      console.log data.toString()
