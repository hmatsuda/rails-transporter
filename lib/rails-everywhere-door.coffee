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
    editor = atom.workspace.getActiveEditor()
    currentFile = editor.getPath()
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
        line = editor.getCursor().getCurrentBufferLine()
        if line.indexOf("render") isnt -1
          if line.indexOf("partial") is -1
            result = line.match(/render\s+(\S+)/)
            partialName = result[1].replace(/['"]/g, '')
            tmplEngine = path.extname(currentFile)
            ext = path.extname(path.basename(currentFile, tmplEngine))
            targetFile = "#{path.dirname(currentFile)}/_#{partialName}#{ext}#{tmplEngine}"
            
    # open file to new tab
    atom.workspaceView.open(targetFile) if fs.existsSync(targetFile)
