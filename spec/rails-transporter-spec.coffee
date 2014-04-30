{WorkspaceView} = require 'atom'
RailsDirector = require '../lib/rails-everywhere-door'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "RailsDirector", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('rails-everywhere-door')

  describe "when the rails-everywhere-door:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.rails-everywhere-door')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'rails-everywhere-door:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.rails-everywhere-door')).toExist()
        atom.workspaceView.trigger 'rails-everywhere-door:toggle'
        expect(atom.workspaceView.find('.rails-everywhere-door')).not.toExist()
