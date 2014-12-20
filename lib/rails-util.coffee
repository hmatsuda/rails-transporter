module.exports =
class RailsUtil
  isController: (filePath) ->
    filePath? and filePath.search(/app\/controllers\/.+_controller.rb$/) isnt -1
    
  isView: (filePath) ->
    filePath? and filePath.indexOf("app/views/") isnt -1

  isSpec: (filePath) ->
    filePath? and filePath.indexOf("_spec.rb") isnt -1
    
  isHelper: (filePath) ->
    filePath? and filePath.search(/app\/helpers\/.+_helper.rb$/) isnt -1

  isModel: (filePath) ->
    filePath? and filePath.indexOf("app/models/") isnt -1
    
  isAsset: (filePath) ->
    filePath? and filePath.indexOf("app/assets/") isnt -1
    
  isMailer: (filePath) ->
    filePath? and filePath.indexOf("app/mailers/") isnt -1

    
