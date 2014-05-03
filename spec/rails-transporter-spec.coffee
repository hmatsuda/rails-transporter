path = require 'path'
fs = require 'fs'
temp = require 'temp'
wrench = require 'wrench'


{WorkspaceView} = require 'atom'
RailsTransporter = require '../lib/rails-transporter'

describe "RailsTransporter", ->
  activationPromise = null
  [viewFinderView, workspaceView] = []

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.workspaceView.openSync(path.join(atom.project.getPath(), 'app/controllers/blogs_controller.rb'))

    activationPromise = atom.packages.activatePackage('rails-transporter')

    
  describe "when the rails-transporter:toggle-view-finder event is triggered", ->
    it "opens View Finder", ->
      expect(atom.workspaceView.find('.select-list')).not.toExist()
      
      editorView = atom.workspaceView.getActiveView()
      editor = editorView.getEditor()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'rails-transporter:toggle-view-finder'

      # Waits until package is activated
      waitsForPromise ->
        activationPromise

      expect(editor.getPath()).toBe path.join atom.project.getPath(), "app/controllers/blogs_controller.rb"
      expect(atom.workspaceView.find('.select-list')).toExist()
