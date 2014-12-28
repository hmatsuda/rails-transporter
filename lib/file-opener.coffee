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
    configExtension = atom.config.get('rails-transporter.newFileExtension')
    @reloadCurrentEditor()

    for rowNumber in [@cusorPos.row..0]
      currentLine = @editor.lineTextForBufferRow(rowNumber)
      result = currentLine.match /^\s*def\s+(\w+)/
      if result?[1]?
        
        if @isController(@currentFile)
          targetFile = @currentFile.replace(path.join('app', 'controllers'), path.join('app', 'views'))
                                   .replace(/_controller\.rb$/, "#{path.sep}#{result[1]}.#{configExtension}")
        else if @isMailer(@currentFile)
          targetFile = @currentFile.replace(path.join('app', 'mailers'), path.join('app', 'views'))
                                   .replace(/\.rb$/, "#{path.sep}#{result[1]}.#{configExtension}")
        else
          targetFile = null
          
        if fs.existsSync targetFile
          @open(targetFile)
        else
          @openDialog(targetFile)
        return
        
    # there were no methods above the line where the command was triggered.
    atom.beep()

  openController: ->
    @reloadCurrentEditor()
    if @isModel(@currentFile)
      resource = path.basename(@currentFile, '.rb')
      targetFile = @currentFile.replace(path.join('app', 'models'), path.join('app', 'controllers'))
                               .replace(resource, "#{pluralize(resource)}_controller")
    else if @isView(@currentFile)
      targetFile = path.dirname(@currentFile)
                   .replace(path.join('app', 'views'), path.join('app', 'controllers')) + '_controller.rb'
    else if @isSpec(@currentFile)
      targetFile = @currentFile.replace(path.join('spec', 'controllers'), path.join('app', 'controllers'))
                               .replace(/_spec\.rb$/, '.rb')

    if fs.existsSync targetFile
      @open(targetFile)
    else
      @openDialog(targetFile)
      

  openModel: ->
    @reloadCurrentEditor()
    if @isController(@currentFile)
      resourceName = pluralize.singular(@currentFile.match(/([\w]+)_controller\.rb$/)[1])
      targetFile = @currentFile.replace(path.join('app', 'controllers'), path.join('app', 'models'))
                               .replace(/([\w]+)_controller\.rb$/, "#{resourceName}.rb")

    else if @isView(@currentFile)
      dir = path.dirname(@currentFile)
      resource = path.basename(dir)
      targetFile = dir.replace(path.join('app', 'views'), path.join('app', 'models'))
                      .replace(resource, "#{pluralize.singular(resource)}.rb")

    else if @isSpec(@currentFile)
      targetFile = @currentFile.replace(path.join('spec', 'models'), path.join('app', 'models'))
                               .replace(/_spec\.rb$/, '.rb')

    if fs.existsSync targetFile
      @open(targetFile)
    else
      @openDialog(targetFile)

  openHelper: ->
    @reloadCurrentEditor()
    if @isController(@currentFile)
      targetFile = @currentFile.replace(path.join('app', 'controllers'), path.join('app', 'helpers'))
                               .replace(/controller\.rb/, 'helper.rb')
    else if @isSpec(@currentFile)
      targetFile = @currentFile.replace(path.join('spec', 'helpers'), path.join('app', 'helpers'))
                               .replace(/_spec\.rb/, '.rb')
    else if @isModel(@currentFile)
      resource = path.basename(@currentFile, '.rb')
      targetFile = @currentFile.replace(path.join('app', 'models'), path.join('app', 'helpers'))
                               .replace(resource, "#{pluralize(resource)}_helper")
    else if @isView(@currentFile)
      targetFile = path.dirname(@currentFile)
                       .replace(path.join('app', 'views'), path.join('app', 'helpers')) + "_helper.rb"

    if fs.existsSync targetFile
      @open(targetFile)
    else
      @openDialog(targetFile)

  openSpec: ->
    @reloadCurrentEditor()
    if @isController(@currentFile)
      targetFile = @currentFile.replace(path.join('app', 'controllers'), path.join('spec', 'controllers'))
                               .replace(/controller\.rb$/, 'controller_spec.rb')
    else if @isHelper(@currentFile)
      targetFile = @currentFile.replace(path.join('app', 'helpers'), path.join('spec', 'helpers'))
                               .replace(/\.rb$/, '_spec.rb')
    else if @isModel(@currentFile)
      targetFile = @currentFile.replace(path.join('app', 'models'), path.join('spec', 'models'))
                               .replace(/\.rb$/, '_spec.rb')
                               
    if fs.existsSync targetFile
      @open(targetFile)
    else
      @openDialog(targetFile)

  openPartial: ->
    @reloadCurrentEditor()
    if @isView(@currentFile)
      if @currentBufferLine.indexOf("render") isnt -1
        if @currentBufferLine.indexOf("partial") is -1
          result = @currentBufferLine.match(/render\s*\(?\s*["'](.+?)["']/)
          targetFile = @partialFullPath(@currentFile, result[1]) if result?[1]?
        else
          result = @currentBufferLine.match(/render\s*\(?\s*\:?partial(\s*=>|:*)\s*["'](.+?)["']/)
          targetFile = @partialFullPath(@currentFile, result[2]) if result?[2]?

    if fs.existsSync targetFile
      @open(targetFile)
    else
      @openDialog(targetFile)

  openAsset: ->
    @reloadCurrentEditor()
    if @isView(@currentFile)
      if @currentBufferLine.indexOf("javascript_include_tag") isnt -1
        result = @currentBufferLine.match(/javascript_include_tag\s*\(?\s*["'](.+?)["']/)
        targetFile = @assetFullPath(result[1], 'js') if result?[1]?
      else if @currentBufferLine.indexOf("stylesheet_link_tag") isnt -1
        result = @currentBufferLine.match(/stylesheet_link_tag\s*\(?\s*["'](.+?)["']/)
        targetFile = @assetFullPath(result[1], 'css') if result?[1]?

    else if @isAsset(@currentFile)
      if @currentBufferLine.indexOf("require ") isnt -1
        result = @currentBufferLine.match(/require\s*(.+?)\s*$/)
        if @currentFile.indexOf("app#{path.sep}assets#{path.sep}javascripts") isnt -1
          targetFile = @assetFullPath(result[1], 'js') if result?[1]?
        else if @currentFile.indexOf("app#{path.sep}assets#{path.sep}stylesheets") isnt -1
          targetFile = @assetFullPath(result[1], 'css') if result?[1]?
      else if @currentBufferLine.indexOf("require_tree ") isnt -1
        return @createAssetFinderView().toggle()
      else if @currentBufferLine.indexOf("require_directory ") isnt -1
        return @createAssetFinderView().toggle()

    @open(targetFile)

  openLayout: ->
    configExtension = atom.config.get('rails-transporter.newFileExtension')
    @reloadCurrentEditor()
    layoutDir = path.join(atom.project.getPaths()[0], 'app', 'views', 'layouts')
    if @isController(@currentFile)
      if @currentBufferLine.indexOf("layout") isnt -1
        result = @currentBufferLine.match(/layout\s*\(?\s*["'](.+?)["']/)
        targetFile = path.join(layoutDir, "#{result[1]}.#{configExtension}") if result?[1]?
      else
        targetFile = @currentFile.replace(path.join('app', 'controllers'), path.join('app', 'views', 'layouts'))
                                 .replace('_controller.rb', ".#{configExtension}")
        unless fs.existsSync(targetFile)
          targetFile = path.join(path.dirname(targetFile), "application.#{configExtension}")

    @open(targetFile)

  ## Private method
  createAssetFinderView: ->
    unless @assetFinderView?
      @assetFinderView = new AssetFinderView()

    @assetFinderView

  reloadCurrentEditor: ->
    @editor = atom.workspace.getActiveTextEditor()
    @currentFile = @editor.getPath()
    @cusorPos = @editor.getLastCursor().getBufferPosition()
    @currentBufferLine = @editor.getLastCursor().getCurrentBufferLine()

  open: (targetFile) ->
    return unless targetFile?
    files = if typeof(targetFile) is 'string' then [targetFile] else targetFile
    for file in files
      atom.workspace.open(file) if fs.existsSync(file)
  
  openDialog: (targetFile) ->
    if targetFile?
      atom.confirm
        message: "No #{targetFile} found"
        detailedMessage: "Shall we create #{targetFile} for you?"
        buttons:
          Yes: ->
            atom.workspace.open(targetFile)
            return
          No: ->
            atom.beep()
            return
    else
      atom.beep()
    

  partialFullPath: (currentFile, partialName) ->
    configExtension = atom.config.get('rails-transporter.newFileExtension')
    
    if partialName.indexOf("/") is -1
      path.join(path.dirname(currentFile), "_#{partialName}.#{configExtension}")
    else
      path.join(atom.project.getPaths()[0], 'app', 'views', path.dirname(partialName), "_#{path.basename(partialName)}.#{configExtension}")

  assetFullPath: (assetName, ext) ->
    switch path.extname(assetName)
      when ".coffee", ".js", ".scss", ".css"
        fileName = path.basename(assetName)
      else
        fileName = "#{path.basename(assetName)}.#{ext}"

    if assetName.match(/^\//)
      path.join(atom.project.getPaths()[0], 'public', path.dirname(assetName), fileName)
    else
      assetsDir = if ext is 'js' then "javascripts" else "stylesheets"
      for location in ['app', 'lib', 'vendor']
        pattern = path.join(atom.project.getPaths()[0], location, 'assets', assetsDir, path.dirname(assetName), "#{fileName}*")
        targetFile = glob.sync(pattern)
        return targetFile if targetFile.length > 0
