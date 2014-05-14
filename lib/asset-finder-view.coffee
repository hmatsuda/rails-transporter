fs = require 'fs'
path = require 'path'

BaseFinderView = require './base-finder-view'

module.exports =
class AssetFinderView extends BaseFinderView
  populate: ->
    @displayFiles.length = 0
    
    editor = atom.workspace.getActiveEditor()
    dir = path.dirname(editor.getPath())
    line = editor.getCursor().getCurrentBufferLine()
    result = line.match(/require_tree\s*([a-zA-Z0-9_\-\./]+)\s*$/)
    
    @loadFolder path.join(dir, result[1])
    @setItems(@displayFiles)

  loadFolder: (folderPath) ->
    for asset in fs.readdirSync(folderPath)
      fullPath = path.join(folderPath, asset)
      stats = fs.statSync fullPath
      if stats.isDirectory()
        @loadFolder fullPath
      else if stats.isFile()
        @displayFiles.push fullPath
