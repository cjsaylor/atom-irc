{$, View} = require 'atom'

module.exports =
class IrcStatusView extends View

  @content: ->
    @span id: 'irc-status', =>
      @a href: '#', class: 'irc-status inline-block', tabindex: '-2', 'IRC'

  initialize: ->
    @on 'click', (e) =>
      e.preventDefault()
      @removeClass().addClass 'connected' if @hasClass 'notify'
      atom.workspaceView.trigger 'irc:toggle'
    @setTooltip("Open IRC chat.")
    @attach()

  destroy: ->
    @unsubscribe()
    @detach()

  attach: =>
    statusBar = atom.workspaceView.statusBar
    if statusBar
      statusBar.appendLeft(this)
    else
      @subscribe(atom.packages.once('activated', @attach))
