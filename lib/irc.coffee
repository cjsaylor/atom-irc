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

  activate: (state) ->
    @ircView = new IrcView(state.ircViewState)
    @ircStatusView = new IrcStatusView()
    @initializeIrc()
    atom.workspaceView.command 'irc:connect', =>
      @initializeIrc true
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
    console.log 'Initializing IRC'
    @client = new Client atom.config.get('irc')
    @bindIrcEvents()

  bindIrcEvents: ->
    @client.on 'message', (from, to, message) =>
      @ircStatusView
        .addClass 'notify'
        .removeClass 'error connected'
      console.log from + ': ' + message
    @client.on 'error', (message) =>
      @ircStatusView.removeClass 'connected notify'
      @ircStatusView.addClass 'error'
      console.error 'IRC Error: ' + message
    @client.on 'join', (channel, who) =>
      console.log '%s has joined %s', who, channel
