util = require 'util'
Irc = require 'irc';
commands = require './commands'
{EventEmitter} = require 'events'

module.exports =
class Connector

  retryCount = 3

  client: null
  emitter: null
  connected: false

  constructor: (options) ->
    @client = new Irc.Client(options.host, options.nickname, {
      channels: options.channels?.split(','),
      debug: options.debug,
      secure: options.secure,
      port: parseInt(options.port || 6697),
      password: options.serverPassword or null,
      selfSigned: true,
      autoConnect: false
      retryCount: retryCount
    });
    @emitter = new EventEmitter()
    @client.on 'notice', (from, to, text) =>
      @client.say('NickServ', 'identify ' + options.password) if from is 'NickServ' and text.indexOf('identify') >= 0

  on: (event, callback) =>
    if event in ['disconnected', 'connected']
      @emitter.on(event, callback)
    else
      @client.on(event, callback)
    @

  sendMessage: (message) ->
    return unless message and @connected
    for command in commands
      if command.pattern.test message
        tokens = command.pattern.exec message
        return @senders()[command.key] tokens
    @senders().default message

  senders: =>
    default: (message) => @client.say atom.config.get('irc.channels'), message
    msg: (tokens) => @client.say tokens[1], tokens[2] if tokens.length is 3
    whois: (tokens) => @client.whois tokens[1] if tokens.length is 2

  connect: =>
    return if @connected
    @client.connect =>
      @connected = true
      @emitter.emit 'connected'

  disconnect: =>
    return if not @connected or @client.conn is null
    @client.disconnect =>
      @connected = false
      @emitter.emit 'disconnected'

  clearEvents: =>
    @client.removeAllListeners()
    @emitter.removeAllListeners()
    @

  disband: =>
    @clearEvents().disconnect()
