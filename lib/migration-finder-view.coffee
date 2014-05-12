path = require 'path'
fs = require 'fs'
{$$, SelectListView} = require 'atom'

module.exports =
class MigrationFinderView extends SelectListView
  migrationFiles: []
  
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
      @attach() if @migrationFiles?.length > 0
      
  populate: ->
    @migrationFiles.length = 0
    migrationDir = path.join(atom.project.getPath(), "db/migrate")
                           
    return unless fs.existsSync migrationDir
    for migrationFile in fs.readdirSync(migrationDir)
      if fs.statSync("#{migrationDir}/#{migrationFile}").isFile()
        @migrationFiles.push "#{migrationDir}/#{migrationFile}"
          
    @setItems(@migrationFiles)

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
