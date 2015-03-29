{CompositeDisposable} = require 'atom'
{$, View} = require 'atom-space-pen-views'

module.exports =
class IrcStatusView extends View

  constructor: ->
    @disposables = new CompositeDisposable
    super

  @content: ->
    @span id: 'irc-status', =>
      @a href: '#', class: 'irc-status inline-block', tabindex: '-2', 'IRC'

  initialize: ->
    @click =>
      @removeClass().addClass('connected') if @hasClass('notify')
      workspaceEl = atom.views.getView(atom.workspace)
      atom.commands.dispatch workspaceEl, 'irc:toggle'

  destroy: ->
    @disposables.dispose()
    @detach()
