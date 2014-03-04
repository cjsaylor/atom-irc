IrcView = require './irc-view'
IrcStatusView = require './irc-status-view'
Client = require './connector'

module.exports =
  ircView: null
  ircStatusView: null
  client: null

  configDefaults:
    host: ""
    port: "6697"
    secure: true
    nickname: ""
    password: ""
    serverPassword: ""
    channels: ""
    debug: false
    connectOnStartup: false

  activate: (state) ->
    @ircView = new IrcView(state.ircViewState)
    @ircStatusView = new IrcStatusView()
    atom.config.observe 'irc', =>
      @initializeIrc true
    @initializeIrc()
    atom.workspaceView.command 'irc:connect', =>
      @client.connect()
    atom.workspaceView.command 'irc:disconnect', =>
      @client.disconnect()

  deactivate: ->
    @ircView.destroy()
    @ircStatusView.destory()

  serialize: ->
    ircViewState: @ircView.serialize()
    ircStatusState: @ircStatusView.serialize()

  initializeIrc: (reinitialized)->
    return if @client is not null and not reinitialized
    if @client is not null
      @client.disconnect()
      @client.clearEvents()
    console.log 'Initializing IRC' if atom.config.get('irc.debug')
    @client = new Client atom.config.get('irc')
    @bindIrcEvents()
    @client.connect() if atom.config.get('irc.connectOnStartup')

  bindIrcEvents: ->
    @client.on 'message', (from, to, message) =>
      @ircStatusView
        .addClass 'notify'
        .removeClass 'error connected'
      # Temporary until view is fleshed out
      console.log from + ': ' + message
    @client.on 'error', (message) =>
      @ircStatusView.removeClass 'connected notify'
      @ircStatusView.addClass 'error'
      console.error 'IRC Error: ' + message if atom.config.get('irc.debug')
    @client.on 'join', (channel, who) =>
      # Temporary until view is fleshed out
      console.log '%s has joined %s', who, channel
