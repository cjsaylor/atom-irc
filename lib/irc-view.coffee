{$, View} = require 'atom'

module.exports =
class IrcView extends View

  ircOutput = null

  scrollToEnd = ->
    ircOutput.scrollTop ircOutput.prop 'scrollHeight'

  @content: ->
    @div class: 'irc overlay from-top native-key-bindings', =>
      @div class: 'input', =>
        @h2 'IRC'
        @div '', class: 'irc-output'
        @input outlet: 'ircMessage', type: 'text', class: 'irc-input native-key-bindings', placeholder: 'Enter your message...'
        @button 'Close', outlet: 'ircClose', class: 'btn'

  initialize: ->
    @ircClose.on 'click', => @detach()
    @ircMessage.on 'keydown', (e) =>
      if e.keyCode is 13 and @ircMessage.val()
        @trigger 'irc:send', [null, @ircMessage.val()]
        @addMessage 'Me', null, @ircMessage.val()
        @ircMessage.val ''
    @subscribe atom.workspaceView, 'core:cancel', => @detach()
    ircOutput = @find('.irc-output')

  show: ->
    atom.workspaceView.append @
    @find('.irc-input').focus()
    scrollToEnd()

  addMessage: (from, to, message) ->
    appendFunction = -> ircOutput.append $('<p/>').text from + ': ' + message
    if ircOutput.prop('scrollHeight') is ircOutput.scrollTop() + ircOutput.outerHeight()
      appendFunction()
      scrollToEnd()
    else
      appendFunction()
