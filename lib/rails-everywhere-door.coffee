ViewFinderView = require './view-finder-view'
path = require 'path'
fs = require 'fs'
pluralize = require 'pluralize'

module.exports =
  activate: (state) ->
    atom.workspaceView.command 'rails-everywhere-door:toggle-view-finder', =>
      @createViewFinderView().toggle()
    atom.workspaceView.command 'rails-everywhere-door:open-model', =>
      @open('model')
    atom.workspaceView.command 'rails-everywhere-door:open-helper', =>
      @open('helper')
    atom.workspaceView.command 'rails-everywhere-door:open-partial-template', =>
      @open('partial')

  deactivate: ->
    if @viewFinderView?
      @viewFinderView.destroy()
      
  createViewFinderView: ->
    unless @viewFinderView?
      @viewFinderView = new ViewFinderView()
      
    @viewFinderView

  open: (type) ->
    currentFile = atom.workspace.getActiveEditor().getPath()
    if currentFile.indexOf("_controller.rb") isnt -1
      resourceName = pluralize.singular(currentFile.match(/([\w]+)_controller\.rb$/)[1])
      if type is 'model'
        targetFile = currentFile.replace('controllers', 'models')
                          .replace(/([\w]+)_controller\.rb$/, "#{resourceName}.rb")
      else if type is 'helper'
        targetFile = currentFile.replace('controllers', 'helpers')
                          .replace('controller.rb', 'helper.rb')
    else if currentFile.indexOf("/views/") isnt -1
      if type is 'partial'
        console.log "open partial template"

      atom.workspaceView.open(targetFile) if fs.existsSync(targetFile)
