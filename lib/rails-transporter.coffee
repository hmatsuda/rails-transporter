ViewFinderView = require './view-finder-view'
MigrationFinderView = require './migration-finder-view'
FileOpener = require './file-opener'

module.exports =
  config:
    viewFileExtension:
      type:        'array'
      description: 'This is the extension of the view files.'
      default:     ['html.erb', 'html.slim', 'html.haml']
      items: 
        type: 'string'
    controllerSpecType:
      type:        'string'
      description: 'This is the type of the controller spec. controllers, requests or features'
      default:     'controllers'
      enum:        ['controllers', 'requests', 'features', 'api', 'integration']

  activate: (state) ->
    atom.commands.add 'atom-workspace',
      'rails-transporter:open-view-finder': =>
        @createViewFinderView().toggle()
      'rails-transporter:open-migration-finder': =>
        @createMigrationFinderView().toggle()
      'rails-transporter:open-model': =>
        @createFileOpener().openModel()
      'rails-transporter:open-helper': =>
        @createFileOpener().openHelper()
      'rails-transporter:open-partial-template': =>
        @createFileOpener().openPartial()
      'rails-transporter:open-test': =>
        @createFileOpener().openTest()
      'rails-transporter:open-spec': =>
        @createFileOpener().openSpec()
      'rails-transporter:open-asset': =>
        @createFileOpener().openAsset()
      'rails-transporter:open-controller': =>
        @createFileOpener().openController()
      'rails-transporter:open-layout': =>
        @createFileOpener().openLayout()
      'rails-transporter:open-view': =>
        @createFileOpener().openView()
      'rails-transporter:open-factory': =>
        @createFileOpener().openFactory()

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
