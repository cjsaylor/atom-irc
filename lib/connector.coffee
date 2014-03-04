Irc = require 'irc';

module.exports =
class Client

  config = []

  constructor: (options) ->
    config = options

    @client = new Irc.Client(config.host, config.nickname, {
      channels: config.channels.split(','),
      debug: config.debug,
      secure: config.secure,
      port: parseInt(config.port),
      password: config.serverPassword,
      selfSigned: true,
      autoConnect: false
    });
    @client.addListener 'notice', (from, to, text) =>
      @client.say('NickServ', 'identify ' + config.password) if from is 'NickServ'

  on: (event, callback) =>
    @client.addListener(event, callback)

  connect: =>
    @client.connect()

  disconnect: =>
    @client.disconnect()
