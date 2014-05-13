ViewFinderView = require './view-finder-view'
MigrationFinderView = require './migration-finder-view'
path = require 'path'
fs = require 'fs'
pluralize = require 'pluralize'

module.exports =
  activate: (state) ->
    atom.workspaceView.command 'rails-transporter:toggle-view-finder', =>
      @createViewFinderView().toggle()
    atom.workspaceView.command 'rails-transporter:toggle-migration-finder', =>
      @createMigrationFinderView().toggle()
    atom.workspaceView.command 'rails-transporter:open-model', =>
      @open('model')
    atom.workspaceView.command 'rails-transporter:open-helper', =>
      @open('helper')
    atom.workspaceView.command 'rails-transporter:open-partial-template', =>
      @open('partial')
    atom.workspaceView.command 'rails-transporter:open-spec', =>
      @open('spec')
    atom.workspaceView.command 'rails-transporter:open-asset', =>
      @open('asset')



  deactivate: ->
    if @viewFinderView?
      @viewFinderView.destroy()
      
  createViewFinderView: ->
    unless @viewFinderView?
      @viewFinderView = new ViewFinderView()
      
    @viewFinderView
    
  createMigrationFinderView: ->
    unless @migrationFinderView?
      @migrationFinderView = new MigrationFinderView()
      
    @migrationFinderView

  open: (type) ->
    editor = atom.workspace.getActiveEditor()
    currentFile = editor.getPath()
    if currentFile.search(/app\/controllers\/.+_controller.rb$/) isnt -1
      resourceName = pluralize.singular(currentFile.match(/([\w]+)_controller\.rb$/)[1])
      if type is 'model'
        targetFile = currentFile.replace('controllers', 'models')
                          .replace(/([\w]+)_controller\.rb$/, "#{resourceName}.rb")
      else if type is 'helper'
        targetFile = currentFile.replace('controllers', 'helpers')
                          .replace('controller.rb', 'helper.rb')
      else if type is 'spec'
        targetFile = currentFile.replace('app/controllers', 'spec/controllers')
                                .replace('controller.rb', 'controller_spec.rb')
                                
    else if currentFile.indexOf("app/models/") isnt -1
      if type is 'spec'
        targetFile = currentFile.replace('app/models', 'spec/models')
                                .replace('.rb', '_spec.rb')
                                
    else if currentFile.indexOf("app/views/") isnt -1
      if type is 'partial'
        line = editor.getCursor().getCurrentBufferLine()
        if line.indexOf("render") isnt -1
          if line.indexOf("partial") is -1
            result = line.match(/render\s+["']([a-zA-Z0-9_\-\./]+)["']/)
            targetFile = @partialFullPath(currentFile, result[1])
          else
            result = line.match(/render\s+\:?partial(\s*=>|:*)\s*["']([a-zA-Z0-9_\-\./]+)["']/)
            targetFile = @partialFullPath(currentFile, result[2])
      else if type is 'asset'
        line = editor.getCursor().getCurrentBufferLine()
        if line.indexOf("javascript_include_tag") isnt -1
          result = line.match(/javascript_include_tag\s*\(?\s*["']([a-zA-Z0-9_\-\./]+)["']/)
          targetFile = @assetManifestFullPath(result[1], 'js')
        else if line.indexOf("stylesheet_link_tag") isnt -1
          result = line.match(/stylesheet_link_tag\s*\(?\s*["']([a-zA-Z0-9_\-\./]+)["']/)
          targetFile = @assetManifestFullPath(result[1], 'css')

    else if currentFile.search(/app\/helpers\/.+_helper.rb$/) isnt -1
      if type is 'spec'
        targetFile = currentFile.replace('app/helpers', 'spec/helpers')
                                .replace('.rb', '_spec.rb')
                                
    else if currentFile.indexOf("app/assets/") isnt -1
      if type is 'asset'
        line = editor.getCursor().getCurrentBufferLine()
        if line.indexOf("require ") isnt -1
          result = line.match(/require\s*([a-zA-Z0-9_\-\./]+)\s*$/)
          targetFile = @assetFileFullPath(result[1], 'js')


    return unless targetFile?
    files = if typeof(targetFile) is 'string' then [targetFile] else targetFile
    for file in files
      atom.workspaceView.open(file) if fs.existsSync(file)

  partialFullPath: (currentFile, partialName) ->
    tmplEngine = path.extname(currentFile)
    ext = path.extname(path.basename(currentFile, tmplEngine))
    if partialName.indexOf("/") is -1
      "#{path.dirname(currentFile)}/_#{partialName}#{ext}#{tmplEngine}"
    else
      "#{atom.project.getPath()}/app/views/#{path.dirname(partialName)}/_#{path.basename(partialName)}#{ext}#{tmplEngine}"
  
  assetManifestFullPath: (assetName, ext) ->
    if path.extname(assetName) is "js"
      fileName = path.basename(assetName)
    else
      fileName = "#{path.basename(assetName)}.#{ext}"
    
    if assetName.match(/^\//)
      "#{atom.project.getPath()}/public/#{path.dirname(assetName)}/#{fileName}"
    else
      assetsDir = if ext is 'js' then "javascripts" else "stylesheets"
      for location in ['app', 'lib', 'vendor']
        "#{atom.project.getPath()}/#{location}/assets/#{assetsDir}/#{path.dirname(assetName)}/#{fileName}"

  assetFileFullPath: (assetName, ext) ->
    switch path.extname(assetName)
      when ".coffee", ".js"
        fileName = path.basename(assetName)
      else
        fileName = "#{path.basename(assetName)}.#{ext}"
    
    if assetName.match(/^\//)
      "#{atom.project.getPath()}/public/#{path.dirname(assetName)}/#{fileName}"
    else
      assetsDir = if ext is 'js' then "javascripts" else "stylesheets"
      for location in ['app', 'lib', 'vendor']
        for fileName in ["#{fileName}.coffee", fileName]
          asset = "#{atom.project.getPath()}/#{location}/assets/#{assetsDir}/#{path.dirname(assetName)}/#{fileName}"
          return asset if fs.existsSync asset
