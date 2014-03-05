Irc = require 'irc';
{EventEmitter} = require 'events'

module.exports =
class Connector

  retryCount = 3

  client: null
  emitter: null
  connected: false

  constructor: (options) ->
    @client = new Irc.Client(options.host, options.nickname, {
      channels: options.channels.split(','),
      debug: options.debug,
      secure: options.secure,
      port: parseInt(options.port),
      password: options.serverPassword,
      selfSigned: true,
      autoConnect: false
    });
    @emitter = new EventEmitter()
    @client.on 'notice', (from, to, text) =>
      @client.say('NickServ', 'identify ' + options.password) if from is 'NickServ'

  on: (event, callback) =>
    if event in ['disconnected', 'connected']
      @emitter.on(event, callback)
    else
      @client.on(event, callback)
    @

  connect: =>
    return if @connected
    @client.connect retryCount, =>
      @connected = true
      @emitter.emit('connected')

  disconnect: =>
    return if not @connected or @client.conn is null
    @client.disconnect =>
      @connected = false
      @emitter.emit('disconnected')

  clearEvents: =>
    @client.removeAllListeners()
    @emitter.removeAllListeners()
    @

  disband: =>
    @clearEvents().disconnect()
