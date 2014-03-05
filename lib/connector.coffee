Irc = require 'irc';

module.exports =
class Connector

  client: null

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
    @client.addListener 'notice', (from, to, text) =>
      @client.say('NickServ', 'identify ' + options.password) if from is 'NickServ'

  on: (event, callback) =>
    @client.addListener(event, callback)

  connect: =>
    @client.connect()

  disconnect: =>
    @client.disconnect()

  clearEvents: =>
    @client.removeAllListeners()
