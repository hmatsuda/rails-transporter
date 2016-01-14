fs = require 'fs'
path = require 'path'
pluralize = require 'pluralize'
changeCase = require 'change-case'
_ = require 'underscore'

DialogView = require './dialog-view'
AssetFinderView = require './asset-finder-view'
RailsUtil = require './rails-util'

module.exports =
class FileOpener
  _.extend this::, RailsUtil::

  openView: ->
    configExtensions = atom.config.get('rails-transporter.viewFileExtension')
    @reloadCurrentEditor()

    for rowNumber in [@cusorPos.row..0]
      currentLine = @editor.lineTextForBufferRow(rowNumber)
      result = currentLine.match /^\s*def\s+(\w+)/
      if result?[1]?
        
        if @isController(@currentFile)
          fileBase = @currentFile.replace(path.join('app', 'controllers'), path.join('app', 'views'))
                                 .replace(/_controller\.rb$/, "#{path.sep}#{result[1]}")
        else if @isMailer(@currentFile)
          fileBase = @currentFile.replace(path.join('app', 'mailers'), path.join('app', 'views'))
                                 .replace(/\.rb$/, "#{path.sep}#{result[1]}")
                       
        for extension in configExtensions
          if fs.existsSync "#{fileBase}.#{extension}"
            targetFile = "#{fileBase}.#{extension}"
            break

        targetFile = "#{fileBase}.#{configExtensions[0]}" unless targetFile?
          
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
                               .replace(///#{resource}\.rb$///, "#{pluralize(resource)}_controller.rb")
    else if @isView(@currentFile)
      targetFile = path.dirname(@currentFile)
                   .replace(path.join('app', 'views'), path.join('app', 'controllers')) + '_controller.rb'
    else if @isHelper(@currentFile)
      targetFile = @currentFile.replace(path.join('app', 'helpers'), path.join('app', 'controllers'))
                               .replace(/_helper\.rb$/, '_controller.rb')
    else if @isTest(@currentFile)
      targetFile = @currentFile.replace(path.join('test', 'controllers'), path.join('app', 'controllers'))
                               .replace(/_test\.rb$/, '.rb')
    else if @isSpec(@currentFile)
      if @currentFile.indexOf('spec/requests') isnt -1
        targetFile = @currentFile.replace(path.join('spec', 'requests'), path.join('app', 'controllers'))
                                 .replace(/_spec\.rb$/, '_controller.rb')
      else
        targetFile = @currentFile.replace(path.join('spec', 'controllers'), path.join('app', 'controllers'))
                                 .replace(/_spec\.rb$/, '.rb')
    else if @isController(@currentFile) and @currentBufferLine.indexOf("include") isnt -1
      concernsDir = path.join(atom.project.getPaths()[0], 'app', 'controllers', 'concerns')
      targetFile = @concernPath(concernsDir, @currentBufferLine)

    if fs.existsSync targetFile
      @open(targetFile)
    else
      @openDialog(targetFile)
      

  openModel: ->
    @reloadCurrentEditor()
    if @isController(@currentFile)
      resourceName = pluralize.singular(@currentFile.match(/([\w]+)_controller\.rb$/)[1])
      
      targetFile = path.join(atom.project.getPaths()[0], 'app', 'models', "#{resourceName}.rb")
      unless fs.existsSync targetFile
        targetFile = @currentFile.replace(path.join('app', 'controllers'), path.join('app', 'models'))
                                 .replace(/([\w]+)_controller\.rb$/, "#{resourceName}.rb")

    else if @isHelper(@currentFile)
      resourceName = pluralize.singular(@currentFile.match(/([\w]+)_helper\.rb$/)[1])
      
      targetFile = path.join(atom.project.getPaths()[0], 'app', 'models', "#{resourceName}.rb")
      unless fs.existsSync targetFile
        targetFile = @currentFile.replace(path.join('app', 'helpers'), path.join('app', 'models'))
                                 .replace(/([\w]+)_helper\.rb$/, "#{resourceName}.rb")

    else if @isView(@currentFile)
      dir = path.dirname(@currentFile)
      resource = path.basename(dir)
      
      targetFile = path.join(atom.project.getPaths()[0], 'app', 'models', "#{resource}.rb")
      unless fs.existsSync targetFile
        targetFile = dir.replace(path.join('app', 'views'), path.join('app', 'models'))
                        .replace(///#{resource}\/*\.*$///, "#{pluralize.singular(resource)}.rb")
                      
    else if @isTest(@currentFile)
      targetFile = @currentFile.replace(path.join('test', 'models'), path.join('app', 'models'))
                               .replace(/_test\.rb$/, '.rb')

    else if @isSpec(@currentFile)
      targetFile = @currentFile.replace(path.join('spec', 'models'), path.join('app', 'models'))
                               .replace(/_spec\.rb$/, '.rb')
                               
    else if @isFactory(@currentFile)
      dir = path.basename(@currentFile, '.rb')
      resource = path.basename(dir)
      targetFile = @currentFile.replace(path.join('spec', 'factories'), path.join('app', 'models'))
                               .replace(///#{resource}\.rb$///, "#{pluralize.singular(resource)}.rb")
                               
    else if @isModel(@currentFile) and @currentBufferLine.indexOf("include") isnt -1
      concernsDir = path.join(atom.project.getPaths()[0], 'app', 'models', 'concerns')
      targetFile = @concernPath(concernsDir, @currentBufferLine)
    
    if fs.existsSync targetFile
      @open(targetFile)
    else
      @openDialog(targetFile)

  openHelper: ->
    @reloadCurrentEditor()
    if @isController(@currentFile)
      targetFile = @currentFile.replace(path.join('app', 'controllers'), path.join('app', 'helpers'))
                               .replace(/controller\.rb/, 'helper.rb')
    else if @isTest(@currentFile)
      targetFile = @currentFile.replace(path.join('test', 'helpers'), path.join('app', 'helpers'))
                               .replace(/_test\.rb/, '.rb')
    else if @isSpec(@currentFile)
      targetFile = @currentFile.replace(path.join('spec', 'helpers'), path.join('app', 'helpers'))
                               .replace(/_spec\.rb/, '.rb')
    else if @isModel(@currentFile)
      resource = path.basename(@currentFile, '.rb')
      targetFile = @currentFile.replace(path.join('app', 'models'), path.join('app', 'helpers'))
                               .replace(///#{resource}\.rb$///, "#{pluralize(resource)}_helper.rb")
    else if @isView(@currentFile)
      targetFile = path.dirname(@currentFile)
                       .replace(path.join('app', 'views'), path.join('app', 'helpers')) + "_helper.rb"

    if fs.existsSync targetFile
      @open(targetFile)
    else
      @openDialog(targetFile)

  openTest: ->
    @reloadCurrentEditor()
    if @isController(@currentFile)
      targetFile = @currentFile.replace(path.join('app', 'controllers'), path.join('test', 'controllers'))
                               .replace(/controller\.rb$/, 'controller_test.rb')
    else if @isHelper(@currentFile)
      targetFile = @currentFile.replace(path.join('app', 'helpers'), path.join('test', 'helpers'))
                               .replace(/\.rb$/, '_test.rb')
    else if @isModel(@currentFile)
      targetFile = @currentFile.replace(path.join('app', 'models'), path.join('test', 'models'))
                               .replace(/\.rb$/, '_test.rb')
    else if @isFactory(@currentFile)
      resource = path.basename(@currentFile.replace(/_test\.rb/, '.rb'), '.rb')
      targetFile = @currentFile.replace(path.join('test', 'factories'), path.join('test', 'models'))
                               .replace("#{resource}.rb", "#{pluralize.singular(resource)}_test.rb")
    
                               
    if fs.existsSync targetFile
      @open(targetFile)
    else
      @openDialog(targetFile)

  openSpec: ->
    @reloadCurrentEditor()
    if @isController(@currentFile)
      controllerSpecType = atom.config.get('rails-transporter.controllerSpecType')
      if controllerSpecType is 'controllers'
        targetFile = @currentFile.replace(path.join('app', 'controllers'), path.join('spec', 'controllers'))
                                 .replace(/controller\.rb$/, 'controller_spec.rb')
      else if controllerSpecType is 'requests'
        targetFile = @currentFile.replace(path.join('app', 'controllers'), path.join('spec', 'requests'))
                                 .replace(/controller\.rb$/, 'spec.rb')
      else if controllerSpecType is 'features'
        targetFile = @currentFile.replace(path.join('app', 'controllers'), path.join('spec', 'features'))
                                 .replace(/controller\.rb$/, 'spec.rb')

    else if @isHelper(@currentFile)
      targetFile = @currentFile.replace(path.join('app', 'helpers'), path.join('spec', 'helpers'))
                               .replace(/\.rb$/, '_spec.rb')
    else if @isModel(@currentFile)
      targetFile = @currentFile.replace(path.join('app', 'models'), path.join('spec', 'models'))
                               .replace(/\.rb$/, '_spec.rb')
    else if @isFactory(@currentFile)
      resource = path.basename(@currentFile.replace(/_spec\.rb/, '.rb'), '.rb')
      targetFile = @currentFile.replace(path.join('spec', 'factories'), path.join('spec', 'models'))
                               .replace("#{resource}.rb", "#{pluralize.singular(resource)}_spec.rb")
    
                               
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
        targetFile = @assetFullPath(result[1], 'javascripts') if result?[1]?
      else if @currentBufferLine.indexOf("stylesheet_link_tag") isnt -1
        result = @currentBufferLine.match(/stylesheet_link_tag\s*\(?\s*["'](.+?)["']/)
        targetFile = @assetFullPath(result[1], 'stylesheets') if result?[1]?

    else if @isAsset(@currentFile)
      if @currentBufferLine.indexOf("require ") isnt -1
        result = @currentBufferLine.match(/require\s*(.+?)\s*$/)
        if @currentFile.indexOf(path.join('app', 'assets', 'javascripts')) isnt -1
          targetFile = @assetFullPath(result[1], 'javascripts') if result?[1]?
        else if @currentFile.indexOf(path.join('app', 'assets', 'stylesheets')) isnt -1
          targetFile = @assetFullPath(result[1], 'stylesheets') if result?[1]?
      else if @currentBufferLine.indexOf("require_tree ") isnt -1
        return @createAssetFinderView().toggle()
      else if @currentBufferLine.indexOf("require_directory ") isnt -1
        return @createAssetFinderView().toggle()

    @open(targetFile)

  openLayout: ->
    configExtensions = atom.config.get('rails-transporter.viewFileExtension')
    @reloadCurrentEditor()
    layoutDir = path.join(atom.project.getPaths()[0], 'app', 'views', 'layouts')
    if @isController(@currentFile)
      if @currentBufferLine.indexOf("layout") isnt -1
        result = @currentBufferLine.match(/layout\s*\(?\s*["'](.+?)["']/)
        
        if result?[1]?
          fileBase = path.join(layoutDir, result[1])
          for extension in configExtensions
            if fs.existsSync "#{fileBase}.#{extension}"
              targetFile = "#{fileBase}.#{extension}"
              break

      else
        fileBase = @currentFile.replace(path.join('app', 'controllers'), path.join('app', 'views', 'layouts'))
                               .replace('_controller.rb', '')
        for extension in configExtensions
          if fs.existsSync "#{fileBase}.#{extension}"
            targetFile = "#{fileBase}.#{extension}"
            break
            
        unless targetFile?
          fileBase = path.join(layoutDir, "application")
          for extension in configExtensions
            if fs.existsSync "#{fileBase}.#{extension}"
              targetFile = "#{fileBase}.#{extension}"
              break
      
    unless fs.existsSync(targetFile)
      targetFile = "#{fileBase}.#{configExtensions[0]}"

    @open(targetFile)
    
  openFactory: ->
    @reloadCurrentEditor()
    if @isModel(@currentFile)
      resource = path.basename(@currentFile, '.rb')
      fileBase = path.dirname(@currentFile.replace(path.join('app', 'models'), path.join('spec', 'factories')))
    else if @isSpec(@currentFile)
      resource = path.basename(@currentFile.replace(/_spec\.rb/, '.rb'), '.rb')
      fileBase = path.dirname(@currentFile.replace(path.join('spec', 'models'), path.join('spec', 'factories')))
      
    if fileBase?
      for fileName in ["#{resource}.rb", "#{pluralize(resource)}.rb"]
        targetFile = path.join(fileBase, fileName)
        if fs.existsSync targetFile
          @open(targetFile)
          break
        @openDialog(targetFile)
    else
      @openDialog(targetFile)

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
    unless @dialogView?
      @dialogView = new DialogView()
      @dialogPanel = atom.workspace.addModalPanel(item: @dialogView, visible: false)
      @dialogView.setPanel(@dialogPanel)
      
    @dialogView.setTargetFile(targetFile)
    @dialogPanel.show()
    @dialogView.focusTextField()

  partialFullPath: (currentFile, partialName) ->
    configExtensions = atom.config.get('rails-transporter.viewFileExtension')
    
    if partialName.indexOf("/") is -1
      fileBase = path.join(path.dirname(currentFile), "_#{partialName}")
      for extension in configExtensions
        if fs.existsSync "#{fileBase}.#{extension}"
          targetFile = "#{fileBase}.#{extension}"
          break
          
      targetFile = "#{fileBase}.#{configExtensions[0]}" unless targetFile?
    else
      fileBase = path.join(atom.project.getPaths()[0], 'app', 'views', path.dirname(partialName), "_#{path.basename(partialName)}")
      for extension in configExtensions
        if fs.existsSync "#{fileBase}.#{extension}"
          targetFile = "#{fileBase}.#{extension}"
          break
      
      targetFile = "#{fileBase}.#{configExtensions[0]}" unless targetFile?
    
    return targetFile

  assetFullPath: (assetName, type) ->
    fileName = path.basename(assetName)
    
    switch path.extname(assetName)
      when ".coffee", ".js", ".scss", ".css"
        ext = ''
      else
        ext = if type is 'javascripts' then '.js' else if 'stylesheets' then '.css'
        
    if assetName.match(/^\//)
      path.join(atom.project.getPaths()[0], 'public', path.dirname(assetName), "#{fileName}#{ext}")
    else
      for location in ['app', 'lib', 'vendor']
        baseName = path.join(atom.project.getPaths()[0], location, 'assets', type, path.dirname(assetName), fileName)
        if type is 'javascripts'
          for fullExt in ["#{ext}.erb", "#{ext}.coffee", "#{ext}.coffee.erb", ext]
            fullPath = baseName + fullExt
            return fullPath if fs.existsSync fullPath
          
        else if type is 'stylesheets'
          for fullExt in ["#{ext}.erb", "#{ext}.scss", "#{ext}.scss.erb", ext]
            fullPath = baseName + fullExt
            return fullPath if fs.existsSync fullPath
            
  concernPath: (concernsDir, currentBufferLine)->
    result = currentBufferLine.match(/include\s+(.+)/)
    
    if result?[1]?
      if result[1].indexOf('::') is -1
        path.join(concernsDir, changeCase.snakeCase(result[1])) + '.rb' 
      else
        concernPaths = (changeCase.snakeCase(concernName) for concernName in result[1].split('::'))
        path.join(concernsDir, concernPaths.join(path.sep)) + '.rb' 
          
    
          
