fs = require 'fs'
BaseFinderView = require './base-finder-view'

module.exports =
class ViewFinderView extends BaseFinderView
  populate: ->
    @displayFiles.length = 0
    currentFile = atom.workspace.getActiveEditor().getPath()
    return if currentFile.indexOf("_controller.rb") == -1
    viewDir = currentFile.replace('controllers', 'views')
                         .replace(/_controller\.rb$/, '')
                           
    return unless fs.existsSync viewDir
    for viewFile in fs.readdirSync(viewDir)
      if fs.statSync("#{viewDir}/#{viewFile}").isFile()
        @displayFiles.push "#{viewDir}/#{viewFile}"
          
    @setItems(@displayFiles)
