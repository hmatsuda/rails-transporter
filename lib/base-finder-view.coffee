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
        
    @subscribe this, 'pane:split-left', =>
      @splitOpenPath (pane, session) -> pane.splitLeft(session)
    @subscribe this, 'pane:split-right', =>
      @splitOpenPath (pane, session) -> pane.splitRight(session)
    @subscribe this, 'pane:split-down', =>
      @splitOpenPath (pane, session) -> pane.splitDown(session)
    @subscribe this, 'pane:split-up', =>
      @splitOpenPath (pane, session) -> pane.splitUp(session)
    
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
