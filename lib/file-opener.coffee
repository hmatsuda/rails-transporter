fs = require 'fs'
path = require 'path'
pluralize = require 'pluralize'
glob = require 'glob'
_ = require 'underscore'

AssetFinderView = require './asset-finder-view'
RailsUtil = require './rails-util'

module.exports =
class FileOpener
  _.extend this::, RailsUtil::

  openView: ->
    @reloadCurrentEditor()

    if @isController(@currentFile)
      for i in [@cusorPos.row..0]
        currentLine = @editor.lineTextForBufferRow(i)
        result = currentLine.match /^\s*def\s+(\w+)/
        if result?[1]?
          targetFiles = glob.sync(@currentFile.replace('controllers', 'views')
                                             .replace(/_controller\.rb$/, "/#{result[1]}.*"))
          if targetFiles.length isnt 0
            for file in targetFiles
              if fs.existsSync file
                @open(file)
          else
            atom.beep()
                
          return

  openController: ->
    @reloadCurrentEditor()
    if @isModel(@currentFile)
      resource = path.basename(@currentFile, '.rb')
      targetFile = @currentFile.replace('models', 'controllers')
                               .replace(resource, "#{pluralize(resource)}_controller")
    else if @isView(@currentFile)
      targetFile = path.dirname(@currentFile)
                       .replace("app/views/", "app/controllers/") + "_controller.rb"
    else if @isSpec(@currentFile)
      targetFile = @currentFile.replace('spec/', 'app/').replace('_spec.rb', '.rb')

    @open(targetFile)
    
  openModel: ->
    @reloadCurrentEditor()
    if @isController(@currentFile)
      resourceName = pluralize.singular(@currentFile.match(/([\w]+)_controller\.rb$/)[1])
      targetFile = @currentFile.replace('controllers', 'models')
                               .replace(/([\w]+)_controller\.rb$/, "#{resourceName}.rb")

    else if @isView(@currentFile)
      dir = path.dirname(@currentFile)
      resource = path.basename(dir)
      targetFile = dir.replace("app/views/", "app/models/")
                      .replace(resource, "#{pluralize.singular(resource)}.rb")
                      
    else if @isSpec(@currentFile)
      targetFile = @currentFile.replace('spec/', 'app/').replace('_spec.rb', '.rb')

    @open(targetFile)
  
  openHelper: ->
    @reloadCurrentEditor()
    if @isController(@currentFile)
      targetFile = @currentFile.replace('controllers', 'helpers')
                               .replace('controller.rb', 'helper.rb')
    else if @isSpec(@currentFile)
      targetFile = @currentFile.replace('spec/helpers', 'app/helpers')
                               .replace('_spec.rb', '.rb')
    else if @isModel(@currentFile)
      resource = path.basename(@currentFile, '.rb')
      targetFile = @currentFile.replace('models', 'helpers')
                               .replace(resource, "#{pluralize(resource)}_helper")
    else if @isView(@currentFile)
      targetFile = path.dirname(@currentFile)
                       .replace("app/views/", "app/helpers/") + "_helper.rb"

    @open(targetFile)
    
  openSpec: ->
    @reloadCurrentEditor()
    if @isController(@currentFile)
      targetFile = @currentFile.replace('app/controllers', 'spec/controllers')
                               .replace('controller.rb', 'controller_spec.rb')
    else if @isHelper(@currentFile)
      targetFile = @currentFile.replace('app/helpers', 'spec/helpers')
                               .replace('.rb', '_spec.rb')
    else if @isModel(@currentFile)
      targetFile = @currentFile.replace('app/models', 'spec/models')
                               .replace('.rb', '_spec.rb')

    @open(targetFile)
      
  openPartial: ->
    @reloadCurrentEditor()
    if @isView(@currentFile)
      if @currentBufferLine.indexOf("render") isnt -1
        
        if @currentBufferLine.indexOf("partial") is -1
          result = @currentBufferLine.match(/render\s*\(?\s*["']([a-zA-Z0-9_\-\./]+)["']/)
          targetFile = @partialFullPath(@currentFile, result[1]) if result?[1]?
        else
          result = @currentBufferLine.match(/render\s*\(?\s*\:?partial(\s*=>|:*)\s*["']([a-zA-Z0-9_\-\./]+)["']/)
          targetFile = @partialFullPath(@currentFile, result[2]) if result?[2]?

    @open(targetFile)
    
  openAsset: ->
    @reloadCurrentEditor()
    if @isView(@currentFile)
      if @currentBufferLine.indexOf("javascript_include_tag") isnt -1
        result = @currentBufferLine.match(/javascript_include_tag\s*\(?\s*["']([a-zA-Z0-9_\-\./]+)["']/)
        targetFile = @assetFullPath(result[1], 'js') if result?[1]?
      else if @currentBufferLine.indexOf("stylesheet_link_tag") isnt -1
        result = @currentBufferLine.match(/stylesheet_link_tag\s*\(?\s*["']([a-zA-Z0-9_\-\./]+)["']/)
        targetFile = @assetFullPath(result[1], 'css') if result?[1]?
        
    else if @isAsset(@currentFile)
      if @currentBufferLine.indexOf("require ") isnt -1
        result = @currentBufferLine.match(/require\s*([a-zA-Z0-9_\-\./]+)\s*$/)
        if @currentFile.indexOf("app/assets/javascripts") isnt -1
          targetFile = @assetFullPath(result[1], 'js') if result?[1]?
        else if @currentFile.indexOf("app/assets/stylesheets") isnt -1
          targetFile = @assetFullPath(result[1], 'css') if result?[1]?
      else if @currentBufferLine.indexOf("require_tree ") isnt -1
        @createAssetFinderView().toggle()
      else if @currentBufferLine.indexOf("require_directory ") isnt -1
        @createAssetFinderView().toggle()

    @open(targetFile)

  openLayout: ->
    @reloadCurrentEditor()
    layoutDir = "#{atom.project.getPath()}/app/views/layouts"
    if @isController(@currentFile)
      if @currentBufferLine.indexOf("layout") isnt -1
        result = @currentBufferLine.match(/layout\s*\(?\s*["']([a-zA-Z0-9_\-\./]+)["']/)
        targetFile = glob.sync("#{layoutDir}/#{result[1]}.*") if result?[1]?
      else
        targetPattern = @currentFile.replace('app/controllers', 'app/views/layouts')
                                    .replace('_controller.rb', '.*')
        targetFile = glob.sync(targetPattern)
        if targetFile.length is 0
          targetFile = glob.sync("#{layoutDir}/application.*")

    @open(targetFile)

  ## Private method
  createAssetFinderView: ->
    unless @assetFinderView?
      @assetFinderView = new AssetFinderView()
      
    @assetFinderView

  reloadCurrentEditor: ->
    @editor = atom.workspace.getActiveEditor()
    @currentFile = @editor.getPath()
    @cusorPos = @editor.getCursor().getBufferPosition()
    @currentBufferLine = @editor.getCursor().getCurrentBufferLine()

  open: (targetFile) ->
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
  
  assetFullPath: (assetName, ext) ->
    switch path.extname(assetName)
      when ".coffee", ".js", ".scss", ".css"
        fileName = path.basename(assetName)
      else
        fileName = "#{path.basename(assetName)}.#{ext}"
    
    if assetName.match(/^\//)
      "#{atom.project.getPath()}/public/#{path.dirname(assetName)}/#{fileName}"
    else
      assetsDir = if ext is 'js' then "javascripts" else "stylesheets"
      for location in ['app', 'lib', 'vendor']
        pattern = "#{atom.project.getPath()}/#{location}/assets/#{assetsDir}/#{path.dirname(assetName)}/#{fileName}*"
        targetFile = glob.sync(pattern)
        console.log targetFile
        return targetFile if targetFile.length > 0
