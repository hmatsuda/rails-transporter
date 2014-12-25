fs = require 'fs'
path = require 'path'
pluralize = require 'pluralize'
_ = require 'underscore'

BaseFinderView = require './base-finder-view'
RailsUtil = require './rails-util'

module.exports =
class ViewFinderView extends BaseFinderView
  _.extend this::, RailsUtil::

  populate: ->
    @displayFiles.length = 0
    currentFile = atom.workspace.getActiveTextEditor().getPath()
    if @isController(currentFile)
      viewDir = currentFile.replace('controllers', 'views')
                           .replace(/_controller\.rb$/, '')
    else if @isModel(currentFile)
      basename = path.basename(currentFile, '.rb')
      viewDir = currentFile.replace('models', 'views')
                           .replace(basename, pluralize(basename))
                           .replace(".rb", "")
    else if @isMailer(currentFile)
      viewDir = currentFile.replace('mailers', 'views')
                           .replace(/\.rb$/, '')
    else
      return

    return unless fs.existsSync viewDir
    for viewFile in fs.readdirSync(viewDir)
      viewPath = path.join(viewDir, viewFile)
      if fs.statSync(viewPath).isFile()
        @displayFiles.push viewPath

    @setItems(@displayFiles)
