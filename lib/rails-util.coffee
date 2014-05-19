module.exports =
class RailsUtil
  isController: (filePath) ->
    filePath.search(/app\/controllers\/.+_controller.rb$/) isnt -1
    
  isView: (filePath) ->
    filePath.indexOf("app/views/") isnt -1

  isSpec: (filePath) ->
    filePath.indexOf("_spec.rb") isnt -1
    
  isHelper: (filePath) ->
    filePath.search(/app\/helpers\/.+_helper.rb$/) isnt -1

  isModel: (filePath) ->
    filePath.indexOf("app/models/") isnt -1
    
  isAsset: (filePath) ->
    filePath.indexOf("app/assets/") isnt -1
    
