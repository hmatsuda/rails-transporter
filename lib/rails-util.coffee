path = require 'path'

module.exports =
class RailsUtil
  isController: (filePath) ->
    filePath? and 
    atom.project.relativize(filePath).indexOf(path.join('app', 'controllers')) isnt -1 and
    filePath.search(/_controller\.rb$/) isnt -1
    
  isView: (filePath) ->
    filePath? and 
    atom.project.relativize(filePath).indexOf(path.join('app', 'views')) isnt -1

  isTest: (filePath) ->
    filePath? and 
    atom.project.relativize(filePath).indexOf(path.join('test')) isnt -1 and
    filePath.search(/_test\.rb$/) isnt -1

  isSpec: (filePath) ->
    filePath? and 
    atom.project.relativize(filePath).indexOf(path.join('spec')) isnt -1 and
    filePath.search(/_spec\.rb$/) isnt -1
    
  isHelper: (filePath) ->
    filePath? and 
    atom.project.relativize(filePath).indexOf(path.join('app', 'helpers')) isnt -1 and
    filePath.search(/_helper\.rb$/) isnt -1

  isModel: (filePath) ->
    filePath? and 
    atom.project.relativize(filePath).indexOf(path.join('app', 'models')) isnt -1 and
    filePath.search(/\.rb$/) isnt -1
    
  isAsset: (filePath) ->
    filePath? and 
    atom.project.relativize(filePath).indexOf(path.join('app', 'assets')) isnt -1
    
  isMailer: (filePath) ->
    filePath? and 
    atom.project.relativize(filePath).indexOf(path.join('app', 'mailers')) isnt -1 and
    filePath.search(/_mailer\.rb$/) isnt -1
    
  isFactory: (filePath) ->
    filePath? and 
    atom.project.relativize(filePath).indexOf(path.join('spec', 'factories')) isnt -1 and
    filePath.search(/\.rb$/) isnt -1
    
    
    

    
