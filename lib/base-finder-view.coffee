path = require 'path'
fs = require 'fs'
{$$, SelectListView} = require 'atom-space-pen-views'


module.exports =
class BaseFinderView extends SelectListView
  displayFiles: []
  
  initialize: ->
    super
    @addClass('overlay from-top')
        
    atom.commands.add @element,
      'pane:split-left': =>
        @splitOpenPath (pane, item) -> pane.splitLeft(items: [item])
      'pane:split-right': =>
        @splitOpenPath (pane, item) -> pane.splitRight(items: [item])
      'pane:split-down': =>
        @splitOpenPath (pane, item) -> pane.splitDown(items: [item])
      'pane:split-up': =>
        @splitOpenPath (pane, item) -> pane.splitUp(items: [item])
    
  destroy: ->
    @cancel()
    @panel?.destroy()
    
  viewForItem: (item) ->
    $$ ->
      @li class: 'two-lines', =>
        @div path.basename(item), class: "primary-line file icon icon-file-text"
        @div atom.project.relativize(item), class: 'secondary-line path no-icon'
  
  confirmed: (item) ->
    atom.workspace.open item
    
  toggle: ->
    if @panel?.isVisible()
      @cancel()
    else
      @populate()
      @show() if @displayFiles?.length > 0
      
  show: ->
    @storeFocusedElement()
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @focusFilterEditor()

  splitOpenPath: (fn) ->
    filePath = @getSelectedItem() ? {}
    return unless filePath

    if pane = atom.workspace.getActivePane()
      atom.project.open(filePath).done (editor) =>
        fn(pane, editor)
    else
      atom.workspace.open filePath

  hide: ->
    @panel?.hide()

  cancelled: ->
    @hide()
