net = require 'net'

{EventEmitter} = require 'events'
{spawn} = require 'child_process'

class Process extends EventEmitter
  constructor: (@name, @command, @cwd) ->

  spawn: ->
    env = {}
    for key, value of process.env
      env[key] = value

    env['PORT'] = @port if @port
    env['PS']   = "#{@name}.1"

    @child = spawn '/bin/sh', ['-c', @command], {env, @cwd}

  kill: (callback) ->
    if @child
      @child.once 'exit', callback if callback
      @child.kill 'SIGKILL'
    else
      callback?()

  terminate: (callback) ->
    if @child
      @child.once 'exit', callback if callback
      @child.kill 'SIGTERM'
    else
      callback?()

  quit: (callback) ->
    if @child
      @child.once 'exit', callback if callback
      @child.kill 'SIGQUIT'
    else
      callback?()

class WebProcess extends Process
  spawn: ->
    @port = getOpenPort()

    super

    tryConnect @port, (err) =>
      unless err
        @emit 'ready'

tryConnect = (port, callback) ->
  socket = new net.Socket
  socket.on 'connect', ->
    socket.destroy()
    callback()
  socket.on 'error', (err) ->
    if err.code is 'ECONNREFUSED'
      socket.connect port
    else
      callback err
  socket.connect port

getOpenPort = ->
  server = net.createServer()
  server.listen 0
  port = server.address().port
  server.close()
  port

exports.createProcess = (name, args...) ->
  if name is 'web'
    new WebProcess name, args...
  else
    new Process name, args...
