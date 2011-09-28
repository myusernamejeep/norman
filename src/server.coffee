{readFile} = require 'fs'
{dirname}  = require 'path'

{createProcess} = require './process'

class Server
  constructor: (@procfile, callback) ->
    @cwd = dirname @procfile

    @processes = {}

    readFile @procfile, 'utf-8', (err, data) =>
      for line in data.split "\n"
        [name, command] = line.split /\s*:\s+/, 2
        continue if name is ''
        @processes[name] = createProcess name, command, @cwd
      callback this

  spawn: (name) ->
    if name
      @processes[name].spawn()
    else
      for name, process of @processes
        process.spawn()

exports.createServer = (args...) ->
  new Server args...
