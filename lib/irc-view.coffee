{ScrollView} = require 'atom'

module.exports =
class IrcView extends ScrollView
  @content: ->
    @div class: 'irc overlay from-top', =>
      @div "The Irc package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
    super()
    atom.workspaceView.command "irc:toggle", => @toggle()

  destroy: ->
    @detach()

  toggle: ->
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
