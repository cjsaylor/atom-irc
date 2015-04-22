{CompositeDisposable} = require 'atom'
url = require 'url'
IrcView = require './irc-view'
IrcStatusView = null
Client = require './connector'

module.exports =
  ircView: null
  ircStatusView: null

  config:
    host:
      type: 'string'
      default: ''
    port:
      type: 'number'
      default: 6697
    secure:
      type: 'boolean'
      default: false
    nickname:
      type: 'string'
      default: ''
    password:
      type: 'string'
      default: ''
    serverPassword:
      type: 'string'
      default: ''
    channels:
      type: 'string'
      default: ''
    debug:
      type: 'boolean'
      default: false
    connectOnStartup:
      type: 'boolean'
      default: false
    evalHtml:
      type: 'boolean'
      default: false
    showJoinMessages:
      type: 'boolean'
      default: false

  activate: ->
    atom.workspace.addOpener (uriToOpen) =>
      {protocol, host} = url.parse uriToOpen
      return unless protocol is 'irc:'
      @ircView if host is 'chat'

    @initializeIrc()

    @ircView = new IrcView(@client)

    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'irc:toggle', =>
      atom.workspace.open('irc://chat', split: 'right').then (ircView) =>
        ircView
          .focusInput()
          .scrollToEnd()
    @subscriptions.add atom.commands.add 'atom-workspace', 'irc:connect', =>
      @client.connect()
    @subscriptions.add atom.commands.add 'atom-workspace', 'irc:disconnect', =>
      @client.disconnect()
    @subscriptions.add atom.config.onDidChange 'irc', =>
      @initializeIrc true

  deactivate: ->
    @ircStatusView.destroy()
    @ircView.destroy()
    @subscriptions.dispose()
    @client.disband()

  initializeIrc: (reinitialized)->
    return if @client and not reinitialized
    @client?.disband()
    console.log 'Initializing IRC' if atom.config.get('irc.debug')
    @client = new Client atom.config.get('irc')
    @client
      .on 'connected', =>
        @ircStatusView.removeClass().addClass('connected')
        @ircView?.addMessage 'CONNECTED', null, 'You have successfully connected!'
      .on 'disconnected', =>
        @ircStatusView.removeClass()
        @ircView?.addMessage 'DISCONNECTED', null, 'You have been disconnected.'
    @bindIrcEvents()
    @client.connect() if atom.config.get('irc.connectOnStartup')

  bindIrcEvents: ->
    @client
      .on 'message', (from, to, message) =>
        @ircStatusView?.removeClass().addClass 'notify'
        @ircView?.addMessage from, to, message
      .on 'error', @errorHandler.bind @
      .on 'abort', @errorHandler.bind @
      .on 'join', (channel, who) =>
        console.log '%s has joined %s', who, channel if atom.config.get 'irc.debug'
        @ircView?.addMessage 'JOINED', null, who + ' has joined ' + channel if atom.config.get('irc.showJoinMessages')
      .on 'whois', (info) => @ircView.addMessage 'WHOIS', null, JSON.stringify info

  errorHandler: (message) ->
    @ircStatusView.removeClass().addClass 'error'
    @client.disconnect() if @client
    console.error 'IRC Error: ' + message.args.join ' ' if message.args and atom.config.get('irc.debug')
    console.error 'IRC Error: ' + message if typeof message is String

  consumeStatusBar: (statusBar) ->
    IrcStatusView = require './irc-status-view'
    @ircStatusView ?= new IrcStatusView()
    statusBar.addLeftTile(item: @ircStatusView, priority: 150)
