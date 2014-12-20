fs = require 'fs'
path = require 'path'

BaseFinderView = require './base-finder-view'

module.exports =
class AssetFinderView extends BaseFinderView
  populate: ->
    @displayFiles.length = 0
    
    editor = atom.workspace.getActiveTextEditor()
    dir = path.dirname(editor.getPath())
    line = editor.getLastCursor().getCurrentBufferLine()
    if line.indexOf("require_tree") isnt -1
      result = line.match(/require_tree\s*([a-zA-Z0-9_\-\./]+)\s*$/)
      @loadFolder(path.join(dir, result[1]), true)
    else if line.indexOf("require_directory") isnt -1
      result = line.match(/require_directory\s*([a-zA-Z0-9_\-\./]+)\s*$/)
      @loadFolder path.join(dir, result[1])
      
    @setItems(@displayFiles)

  loadFolder: (folderPath, recursive = false) ->
    for asset in fs.readdirSync(folderPath)
      fullPath = path.join(folderPath, asset)
      stats = fs.statSync fullPath
      if stats.isDirectory() and recursive is true
        @loadFolder fullPath
      else if stats.isFile()
        @displayFiles.push fullPath
