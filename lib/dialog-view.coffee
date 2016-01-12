{View, TextEditorView} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

module.exports =
class DialogView extends View
  @content: ->
    @div tabIndex: -1, class: 'padded rails-transporter', =>
      @div class: "block", =>
        @label "No target file found. Enter the path for the file to open"
        @subview 'fileEditor', new TextEditorView(mini: true, placeholder: '/path/to/file')

  initialize: ->
    @subscriptions = new CompositeDisposable
    
    @subscriptions.add atom.commands.add @fileEditor.element,
      'core:confirm': => @openFile()
      'core:cancel': => @panel?hide()

    @subscriptions.add atom.commands.add @element,
      'core:close': => @panel?.hide()
      'core:cancel': => @panel?.hide()

  destroy: ->
    @subscriptions?.dispose()

  setPanel: (@panel) ->
    @subscriptions.add @panel.onDidChangeVisible (visible) =>
      if visible then @didShow() else @didHide()
      
  didShow: ->
    # todo

  didHide: ->
    workspaceElement = atom.views.getView(atom.workspace)
    workspaceElement.focus()
    
  openFile: ->
    atom.workspace.open(@fileEditor.getText())
    @panel?.hide()
    
  setTargetFile: (path) =>
    if path?
      projectPath = atom.project.relativizePath(path)
    else
      currentFile = atom.workspace.getActiveTextEditor().getPath()
      projectPath = atom.project.relativizePath(currentFile)
      
    @fileEditor.setText(projectPath[1])

  focusTextField: =>
    @fileEditor.focus()
