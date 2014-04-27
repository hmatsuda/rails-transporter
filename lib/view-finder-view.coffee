path = require 'path'
fs = require 'fs'
{$$, SelectListView} = require 'atom'

module.exports =
class ViewFinderView extends SelectListView
  viewFiles: []
  
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
        @div item, class: 'secondary-line path no-icon'
  
  confirmed: (item) ->
    atom.workspaceView.open item
    
  toggle: ->
    if @hasParent()
      @cancel()
    else
      @populate()
      @attach() if @viewFiles?.length > 0
      
  populate: ->
    @viewFiles.length = 0
    currentFile = atom.workspace.getActiveEditor().getPath()
    return if currentFile.indexOf("_controller.rb") == -1
    viewDir = currentFile.replace('controllers', 'views')
                         .replace(/_controller\.rb$/, '')
                           
    return unless fs.existsSync viewDir
    for viewFile in fs.readdirSync(viewDir)
      if fs.statSync("#{viewDir}/#{viewFile}").isFile()
        @viewFiles.push "#{viewDir}/#{viewFile}"
          
    @setItems(@viewFiles)

  attach: ->
    @storeFocusedElement()
    atom.workspaceView.append(this)
    @focusFilterEditor()

  splitOpenPath: (fn) ->
    filePath = @getSelectedItem() ? {}
    return unless filePath

    if pane = atom.workspaceView.getActivePane()
      atom.project.open(filePath).done (editor) =>
        fn(pane, editor)
    else
      atom.workspaceView.open filePath
