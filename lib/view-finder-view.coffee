fs = require 'fs'
path = require 'path'
pluralize = require 'pluralize'
BaseFinderView = require './base-finder-view'

module.exports =
class ViewFinderView extends BaseFinderView
  populate: ->
    @displayFiles.length = 0
    currentFile = atom.workspace.getActiveEditor().getPath()
    if currentFile.indexOf("app/controllers/") isnt -1
      viewDir = currentFile.replace('controllers', 'views')
                           .replace(/_controller\.rb$/, '')
    else if currentFile.indexOf("app/models/") isnt -1
      basename = path.basename(currentFile, '.rb')
      viewDir = currentFile.replace('models', 'views')
                           .replace(basename, pluralize(basename))
                           .replace(".rb", "")
    else
      return

    return unless fs.existsSync viewDir
    for viewFile in fs.readdirSync(viewDir)
      if fs.statSync("#{viewDir}/#{viewFile}").isFile()
        @displayFiles.push "#{viewDir}/#{viewFile}"
          
    @setItems(@displayFiles)
