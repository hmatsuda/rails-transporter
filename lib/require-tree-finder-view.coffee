fs = require 'fs'
path = require 'path'

BaseFinderView = require './base-finder-view'

module.exports =
class RequireTreeFinderView extends BaseFinderView
  populate: ->
    @displayFiles.length = 0
    
    editor = atom.workspace.getActiveEditor()
    dir = path.dirname(editor.getPath())
    line = editor.getCursor().getCurrentBufferLine()
    result = line.match(/require_tree\s*([a-zA-Z0-9_\-\./]+)\s*$/)
    
    for asset in fs.readdirSync(path.join(dir, result[1]))
      if fs.statSync(asset).isFile()
        @displayFiles.push "#{dir}/#{asset}"

          
    @setItems(@displayFiles)
