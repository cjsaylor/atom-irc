{$, View} = require 'atom'

module.exports =
class IrcStatusView extends View

  @content: ->
    @a href: '#', class: 'irc-status inline-block', tabindex: '-2', 'IRC'

  initialize: ->
    @on 'click', =>
      @removeClass 'error notify'
      @addClass 'connected'
      atom.workspaceView.trigger 'irc:toggle'
      false
    @setTooltip("Open IRC chat.")
    @attach()

  attach: =>
    statusBar = atom.workspaceView.statusBar
    if statusBar
      statusBar.appendLeft(this)
    else
      @subscribe(atom.packages.once('activated', @attach))
