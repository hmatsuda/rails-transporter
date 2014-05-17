ViewFinderView = require './view-finder-view'
MigrationFinderView = require './migration-finder-view'
FileOpener = require './file-opener'

module.exports =
  activate: (state) ->
    atom.workspaceView.command 'rails-transporter:open-view-finder', =>
      @createViewFinderView().toggle()
    atom.workspaceView.command 'rails-transporter:toggle-migration-finder', =>
      @createMigrationFinderView().toggle()
    atom.workspaceView.command 'rails-transporter:open-model', =>
      @createFileOpener().openModel()
    atom.workspaceView.command 'rails-transporter:open-helper', =>
      @createFileOpener().openHelper()
    atom.workspaceView.command 'rails-transporter:open-partial-template', =>
      @createFileOpener().openPartial()
    atom.workspaceView.command 'rails-transporter:open-spec', =>
      @createFileOpener().openSpec()
    atom.workspaceView.command 'rails-transporter:open-asset', =>
      @createFileOpener().openAsset()
    atom.workspaceView.command 'rails-transporter:open-controller', =>
      @createFileOpener().openController()

  deactivate: ->
    if @viewFinderView?
      @viewFinderView.destroy()
    if @migrationFinderView?
      @migrationFinderView.destroy()
      
  createFileOpener: ->
    unless @fileOpener?
      @fileOpener = new FileOpener()
      
    @fileOpener

  createViewFinderView: ->
    unless @viewFinderView?
      @viewFinderView = new ViewFinderView()
      
    @viewFinderView
    
  createMigrationFinderView: ->
    unless @migrationFinderView?
      @migrationFinderView = new MigrationFinderView()
      
    @migrationFinderView
