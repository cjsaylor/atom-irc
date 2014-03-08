{$, ScrollView} = require 'atom'

module.exports =
class IrcView extends ScrollView

  @ircOutput: null
  @package: null

  @content: ->
    @div class: 'irc native-key-bindings', =>
      @div class: 'input', =>
        @div '', class: 'irc-output native-key-bindings'
        @input outlet: 'ircMessage', type: 'text', class: 'irc-input native-key-bindings', placeholder: 'Enter your message...'

  constructor: (state) ->
    @ircOutput = state
    super

  initialize: ->
    @handleEvents
    if not @ircOutput
      @ircOutput = @find('.irc-output')

  getTitle: ->
    'IRC ' + atom.config.get('irc.channels')

  handleEvents: ->
    @subscribe this, 'core:move-up', => @scrollUp()
    @subscribe this, 'core:move-down', => @scrollDown()
    @ircMessage.on 'keydown', (e) =>
      if e.keyCode is 13 and @ircMessage.val()
        @trigger 'irc:send', [null, @ircMessage.val()]
        @addMessage 'Me', null, @ircMessage.val()
        @ircMessage.val ''
    @

  addMessage: (from, to, message) =>
    ircOutput = @find('.irc-output')
    appendFunction = => ircOutput.append $('<p/>').text from + ': ' + message
    if ircOutput.prop('scrollHeight') is ircOutput.scrollTop() + ircOutput.outerHeight()
      appendFunction()
      ircOutput.scrollTop ircOutput.prop 'scrollHeight'
    else
      appendFunction()
