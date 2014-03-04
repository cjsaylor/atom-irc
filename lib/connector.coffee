Irc = require 'irc';

module.exports =
class Client

  config = []

  constructor: (options) ->
    config = options
    console.log config
    @client = new Irc.Client(config.host, config.nickname, {
      channels: config.channels.split ',',
      debug: config.debug,
      secure: config.secure,
      port: parseInt(config.port),
      password: config.serverPassword,
      selfSigned: true
    });
    @client.addListener 'error', (message) =>
      console.log('Error: ' + message)
    @client.addListener 'notice', (from, to, text) =>
      @client.say('NickServ', 'identify ' + config.password)

  on: (event, callback) =>
    console.log 'Binding ' + event
    @client.addListener(event, callback)

  disconnect: =>
    @client.disconnect()
