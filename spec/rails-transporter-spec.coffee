{WorkspaceView} = require 'atom'
RailsDirector = require '../lib/rails-transporter'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "RailsTransporter", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('rails-transporter')

  describe "when the rails-transporter:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.rails-transporter')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'rails-transporter:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.rails-transporter')).toExist()
        atom.workspaceView.trigger 'rails-transporter:toggle'
        expect(atom.workspaceView.find('.rails-transporter')).not.toExist()
