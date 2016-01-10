fs = require 'fs'
path = require 'path'

BaseFinderView = require './base-finder-view'

module.exports =
class ViewFinderView extends BaseFinderView
  populate: ->
    @displayFiles.length = 0
    migrationDir = path.join(atom.project.getPaths()[0], "db", "migrate")
                           
    return unless fs.existsSync migrationDir
    for migrationFile in fs.readdirSync(migrationDir) by -1
      filePath = path.join(migrationDir, migrationFile)
      if fs.statSync(filePath).isFile()
        @displayFiles.push filePath
          
    @setItems(@displayFiles)
