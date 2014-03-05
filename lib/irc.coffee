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

  activate: (state) ->
    @ircView = new IrcView(state.ircViewState)
    @ircStatusView = new IrcStatusView()
    @initializeIrc()
    atom.config.observe 'irc', =>
      @initializeIrc true
    atom.workspaceView.command 'irc:connect', =>
      @client.connect()
    atom.workspaceView.command 'irc:disconnect', =>
      @client.disconnect()

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
      .on 'connected', =>
        @ircStatusView
          .removeClass('error notify')
          .addClass('connected')
      .on 'disconnected', =>
        @ircStatusView.removeClass('error notify connected')
    @bindIrcEvents()
    @client.connect() if atom.config.get('irc.connectOnStartup')

  bindIrcEvents: ->
    @client
      .on 'message', (from, to, message) =>
        @ircStatusView
          .addClass 'notify'
          .removeClass 'error connected'
        # Temporary until view is fleshed out
        console.log from + ': ' + message
      .on 'error', @errorHandler.bind @
      .on 'abort', @errorHandler.bind @
      .on 'join', (channel, who) =>
        # Temporary until view is fleshed out
        console.log '%s has joined %s', who, channel

  errorHandler: (message) ->
    @ircStatusView.removeClass 'connected notify'
    @ircStatusView.addClass 'error'
    console.error 'IRC Error: ' + message if atom.config.get('irc.debug')
