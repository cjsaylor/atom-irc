{$, ScrollView} = require 'atom-space-pen-views'
util = require 'util'
Autolinker = require 'autolinker'

module.exports =
class IrcView extends ScrollView

  @ircOutput: null
  @package: null

  @content: ->
    @div class: 'irc native-key-bindings', tabindex: -1, =>
      @div class: 'input', =>
        @div '', class: 'irc-output native-key-bindings'
        @input outlet: 'ircMessage', type: 'text', class: 'irc-input native-key-bindings', placeholder: 'Enter your message...'

  initialize: (@client) ->
    @sendCommand = atom.commands.add 'atom-workspace', 'irc:send', (e) =>
      @client.sendMessage e.detail.message
    @autolinker = new Autolinker(newWindow: false, email: false, twitter: false, phone: false)

  attached: ->
    @ircOutput = @find('.irc-output')
    @ircMessage.on 'keydown', (e) =>
      if e.keyCode is 13 and @ircMessage.val()
        workspaceEl = atom.views.getView(atom.workspace)
        atom.commands.dispatch workspaceEl, 'irc:send', message: @ircMessage.val()
        @addMessage atom.config.get('irc.nickname'), null, @ircMessage.val()
        @ircMessage.val ''

  getTitle: ->
    'IRC ' + atom.config.get('irc.channels')

  destroy: ->
    @sendCommand.dispose()
    @detach()

  addMessage: (from, to, message) =>
    ircOutput = @find('.irc-output')
    line = $('<p/>')
    line.addClass 'pm' if to is atom.config.get 'irc.nickname'
    line.addClass 'whois' if from is 'WHOIS'
    line.addClass 'from-me' if from is atom.config.get 'irc.nickname'
    line.addClass "from-#{from}"

    ts = $('<span>')
    ts.addClass 'ts'
    ts.text(util.format '%s', new Date().toLocaleTimeString())

    un = $('<span>')
    un.addClass 'un'
    un.text(util.format '%s', from)

    msg = $('<span>')
    un.addClass 'msg'
    if atom.config.get('irc.evalHtml')
      msg.addClass 'html'
      msg.html(util.format '%s', @autolinker.link(message))
    else
      msg.addClass 'txt'
      msg.text(util.format '%s', message)

    appendFunction = => ircOutput.append line.append ts, [un, msg]
    if ircOutput.prop('scrollHeight') is ircOutput.scrollTop() + ircOutput.outerHeight()
      appendFunction()
      ircOutput.scrollTop ircOutput.prop 'scrollHeight'
    else
      appendFunction()
