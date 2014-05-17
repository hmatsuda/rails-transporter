ViewFinderView = require './view-finder-view'
MigrationFinderView = require './migration-finder-view'
FileOpener = require './file-opener'

module.exports =
  activate: (state) ->
    atom.workspaceView.command 'rails-transporter:toggle-view-finder', =>
      @createViewFinderView().toggle()
    atom.workspaceView.command 'rails-transporter:toggle-migration-finder', =>
      @createMigrationFinderView().toggle()
    atom.workspaceView.command 'rails-transporter:open-model', =>
      @createFileOpener().open('model')
    atom.workspaceView.command 'rails-transporter:open-helper', =>
      @createFileOpener().open('helper')
    atom.workspaceView.command 'rails-transporter:open-partial-template', =>
      @createFileOpener().open('partial')
    atom.workspaceView.command 'rails-transporter:open-spec', =>
      @createFileOpener().open('spec')
    atom.workspaceView.command 'rails-transporter:open-asset', =>
      @createFileOpener().open('asset')
    atom.workspaceView.command 'rails-transporter:open-controller', =>
      @createFileOpener().open('controller')


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
