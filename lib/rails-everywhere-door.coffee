ViewFinderView = require './view-finder-view'
path = require 'path'
fs = require 'fs'
pluralize = require 'pluralize'

module.exports =
  activate: (state) ->
    atom.workspaceView.command 'rails-everywhere-door:toggle-view-finder', =>
      @createViewFinderView().toggle()
    atom.workspaceView.command 'rails-everywhere-door:go-to-model', =>
      @goToModel()

  deactivate: ->
    if @viewFinderView?
      @viewFinderView.destroy()
      
  createViewFinderView: ->
    unless @viewFinderView?
      @viewFinderView = new ViewFinderView()
      
    @viewFinderView

  goToModel: ->
    currentFile = atom.workspace.getActiveEditor().getPath()
    if currentFile.indexOf("_controller.rb") isnt -1
      resourceName = pluralize.singular(currentFile.match(/([\w]+)_controller\.rb$/)[1])
      modelPath = currentFile.replace('controllers', 'models')
                             .replace(/([\w]+)_controller\.rb$/, "#{resourceName}.rb")
      
      atom.workspaceView.open(modelPath) if fs.existsSync(modelPath)
