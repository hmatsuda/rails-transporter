path = require 'path'
fs = require 'fs'
{SelectListView} = require 'atom'
{$$} = require 'atom-space-pen-views'


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
    @remove()
    
  viewForItem: (item) ->
    $$ ->
      @li class: 'two-lines', =>
        @div path.basename(item), class: "primary-line file icon icon-file-text"
        @div atom.project.relativize(item), class: 'secondary-line path no-icon'
  
  confirmed: (item) ->
    atom.workspace.open item
    
  toggle: ->
    if @hasParent()
      @cancel()
    else
      @populate()
      @attach() if @displayFiles?.length > 0
      
  attach: ->
    @storeFocusedElement()
    atom.workspace.addModalPanel(item: this)
    @focusFilterEditor()

  splitOpenPath: (fn) ->
    filePath = @getSelectedItem() ? {}
    return unless filePath

    if pane = atom.workspace.getActivePaneView()
      atom.project.open(filePath).done (editor) =>
        fn(pane, editor)
    else
      atom.workspace.open filePath
