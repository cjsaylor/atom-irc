IrcView = require './irc-view'
IrcStatusView = require './irc-status-view'
Client = require './connector'

module.exports =
  ircView: null
  ircStatusView: null
  client: null

  configDefaults:
    host: ""
    port: ""
    secure: false
    nickname: ""
    password: ""
    serverPassword: ""
    channels: ""
    debug: false
    connectOnStartup: false

  activate: ->
    @ircStatusView = new IrcStatusView()
    @ircView = new IrcView()
    @ircView.command 'irc:send', (e, to, message) =>
      to = to || atom.config.get 'irc.channels'
      @client.sendMessage to, message
    @initializeIrc()
    atom.workspaceView.command 'irc:toggle', =>
      @ircView.show()
    atom.workspaceView.command 'irc:connect', =>
      @client.connect()
    atom.workspaceView.command 'irc:disconnect', =>
      @client.disconnect()
    atom.config.observe 'irc', =>
      @initializeIrc true

  deactivate: ->
    @ircView.destroy()
    @ircStatusView.destory()
    @client.disband()

  serialize: ->
    ircViewState: @ircView.serialize()
    ircStatusState: @ircStatusView.serialize()

  initializeIrc: (reinitialized)->
    return if @client and not reinitialized
    @client.disband() unless @client is null
    console.log 'Initializing IRC' if atom.config.get('irc.debug')
    @client = new Client atom.config.get('irc')
    @client
      .on 'connected', => @ircStatusView.removeClass().addClass('connected')
      .on 'disconnected', => @ircStatusView.removeClass()
    @bindIrcEvents()
    @client.connect() if atom.config.get('irc.connectOnStartup')

  bindIrcEvents: ->
    @client
      .on 'message', (from, to, message) =>
        @ircStatusView.removeClass().addClass 'notify'
        @ircView.addMessage(from, to, message)
      .on 'error', @errorHandler.bind @
      .on 'abort', @errorHandler.bind @
      .on 'join', (channel, who) =>
        console.log '%s has joined %s', who, channel if atom.config.get 'irc.debug'

  errorHandler: (message) ->
    @ircStatusView.removeClass().addClass 'error'
    console.error 'IRC Error: ' + message if atom.config.get('irc.debug')
