url = require 'url'
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
    evalHtml: false

  activate: ->
    @ircStatusView = new IrcStatusView()
    @ircView = new IrcView()
    @initializeIrc()
    atom.workspaceView.command 'irc:toggle', =>
      atom.workspace.open('irc://chat', split: 'right', searchAllPanes: true).done (ircView) =>
        ircView.command 'irc:send', (e, message) =>
          @client.sendMessage message
        ircView.handleEvents()
        ircView.find('.irc-input').focus()
    atom.workspaceView.command 'irc:connect', =>
      @client.connect()
    atom.workspaceView.command 'irc:disconnect', =>
      @client.disconnect()
    atom.config.onDidChange 'irc', =>
      @initializeIrc true
    atom.workspace.registerOpener (uriToOpen) =>
      {protocol, host} = url.parse uriToOpen
      return unless protocol is 'irc:'
      if host is 'chat'
        @ircView
  deactivate: ->
    @ircView.destroy()
    @ircStatusView.destroy()
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
        @ircView.addMessage from, to, message
      .on 'error', @errorHandler.bind @
      .on 'abort', @errorHandler.bind @
      .on 'join', (channel, who) =>
        console.log '%s has joined %s', who, channel if atom.config.get 'irc.debug'
      .on 'whois', (info) => @ircView.addMessage 'WHOIS', null, JSON.stringify info

  errorHandler: (message) ->
    @ircStatusView.removeClass().addClass 'error'
    @client.disconnect() if @client
    console.error 'IRC Error: ' + message.args.join ' ' if message.args and atom.config.get('irc.debug')
    console.error 'IRC Error: ' + message if typeof message is String
