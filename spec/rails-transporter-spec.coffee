path = require 'path'
fs = require 'fs'
temp = require 'temp'
wrench = require 'wrench'
{$, $$} = require 'atom-space-pen-views'


{Point} = require 'atom'
RailsTransporter = require '../lib/rails-transporter'

describe "RailsTransporter", ->
  activationPromise = null
  [workspaceElement, viewFinderView, editor] = []

  beforeEach ->
    # set Project Path to temporaly directory.
    tempPath = fs.realpathSync(temp.mkdirSync('atom'))
    fixturesPath = atom.project.getPaths()[0]
    wrench.copyDirSyncRecursive(fixturesPath, tempPath, forceDelete: true)
    atom.project.setPaths([tempPath])
    
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('rails-transporter')
    
  describe "open-migration-finder behavior", ->
    describe "when the rails-transporter:open-migration-finder event is triggered", ->
      # it "shows the MigrationFinder or hides it if it's already showing", ->
      # 
      #   atom.commands.dispatch workspaceElement, 'rails-transporter:open-migration-finder'
      # 
      #   waitsForPromise ->
      #     activationPromise
      # 
      #   runs ->
      #     expect(workspaceElement.querySelector('.select-list')).toExist()
  
      it "shows all migration paths and selects the first", ->
        atom.commands.dispatch workspaceElement, 'rails-transporter:open-migration-finder'
  
        waitsForPromise ->
          activationPromise
  
        runs ->
          migrationDir = path.join(atom.project.getPaths()[0], 'db', 'migrate')
          expect(workspaceElement.querySelectorAll('.select-list li').length).toBe fs.readdirSync(migrationDir).length
          for migration in fs.readdirSync(migrationDir)
            expect($(workspaceElement).find(".select-list .primary-line:contains(#{migration})")).toExist()
            expect($(workspaceElement).find(".select-list .secondary-line:contains(#{atom.project.relativize(path.join(migrationDir, migration))})")).toExist()
          
          # expect(workspaceElement.querySelector(".select-list li")).toHaveClass 'two-lines selected'
  
  describe "open-view behavior", ->
    describe "when active editor opens controller", ->
      describe "open file", ->
        beforeEach ->
          waitsForPromise ->
            atom.workspace.open(path.join(atom.project.getPaths()[0], 'app', 'controllers', 'blogs_controller.rb'))
      
        it "opens related view", ->
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(9, 0)
          atom.commands.dispatch workspaceElement, 'rails-transporter:open-view'
      
          # Waits until package is activated and active panes count is 2
          waitsFor ->
            activationPromise
            atom.workspace.getActivePane().getItems().length == 2
      
          runs ->
            viewPath = path.join(atom.project.getPaths()[0], 'app', 'views', 'blogs', 'index.html.erb')
            editor = atom.workspace.getActiveTextEditor()
            expect(editor.getPath()).toBe viewPath
            expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^<h1>Listing blogs<\/h1>$/
            
      describe "open file for fallbacks", ->
        beforeEach ->
          waitsForPromise ->
            atom.config.set('rails-transporter.viewFileExtension', ['json.jbuilder'])
            atom.workspace.open(path.join(atom.project.getPaths()[0], 'app', 'controllers', 'api', 'blogs_controller.rb'))
      
        it "opens related view", ->
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(4, 0)
          atom.commands.dispatch workspaceElement, 'rails-transporter:open-view'
      
          # Waits until package is activated and active panes count is 2
          waitsFor ->
            activationPromise
            atom.workspace.getActivePane().getItems().length == 2
      
          runs ->
            viewPath = path.join(atom.project.getPaths()[0], 'app', 'views', 'api', 'blogs', 'index.json.jbuilder')
            editor = atom.workspace.getActiveTextEditor()
            expect(editor.getPath()).toBe viewPath
            expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^json.array!(@blogs) do |blog|$/


  describe "open-view-finder behavior", ->
  
    describe "when active editor opens controller", ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(path.join(atom.project.getPaths()[0], 'app', 'controllers', 'blogs_controller.rb'))
    
      describe "when the rails-transporter:open-view-finder event is triggered", ->
        # it "shows the ViewFinder or hides it if it's already showing", ->
        #   expect(workspaceElement.querySelector('.select-list')).not.toExist()
        # 
        #   # This is an activation event, triggering it will cause the package to be
        #   # activated.
        #   atom.commands.dispatch workspaceElement, 'rails-transporter:open-view-finder'
        # 
        #   # Waits until package is activated
        #   waitsForPromise ->
        #     activationPromise
        # 
        #   runs ->
        #     expect(workspaceElement.querySelector('.select-list')).toExist()
        #     atom.commands.dispatch workspaceElement, 'rails-transporter:open-view-finder'
        #     expect(workspaceElement.querySelector('.select-list')).not.toExist()
    
        it "shows all relative view paths for the current controller and selects the first", ->
          atom.commands.dispatch workspaceElement, 'rails-transporter:open-view-finder'
    
          # Waits until package is activated
          waitsForPromise ->
            activationPromise
    
          runs ->
            viewDir = path.join(atom.project.getPaths()[0], 'app', 'views', 'blogs')
            expect($(workspaceElement).find('.select-list li').length).toBe fs.readdirSync(viewDir).length
            for view in fs.readdirSync(viewDir)
              expect($(workspaceElement).find(".select-list .primary-line:contains(#{view})")).toExist()
              expect($(workspaceElement).find(".select-list .secondary-line:contains(#{atom.project.relativize(path.join(viewDir, view))})")).toExist()
    
            expect($(workspaceElement).find(".select-list li:first")).toHaveClass 'two-lines selected'
            # hide view-finder for next test
            atom.commands.dispatch workspaceElement, 'rails-transporter:open-view-finder'
            
    describe "when active editor opens mailer", ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(path.join(atom.project.getPaths()[0], 'app', 'mailers', 'notification_mailer.rb'))
    
      describe "when the rails-transporter:open-view-finder event is triggered", ->
        # it "shows the ViewFinder or hides it if it's already showing", ->
        #   expect(workspaceElement.querySelector('.select-list')).not.toExist()
        # 
        #   # This is an activation event, triggering it will cause the package to be
        #   # activated.
        #   atom.commands.dispatch workspaceElement, 'rails-transporter:open-view-finder'
        # 
        #   # Waits until package is activated
        #   waitsForPromise ->
        #     activationPromise
        # 
        #   runs ->
        #     expect(workspaceElement.querySelector('.select-list')).toExist()
        #     atom.commands.dispatch workspaceElement, 'rails-transporter:open-view-finder'
        #     expect(workspaceElement.querySelector('.select-list')).not.toExist()
    
        # it "shows all relative view paths for the current controller and selects the first", ->
        #   atom.commands.dispatch workspaceElement, 'rails-transporter:open-view-finder'
        # 
        #   # Waits until package is activated
        #   waitsForPromise ->
        #     activationPromise
        # 
        #   runs ->
        #     viewDir = path.join(atom.project.getPaths()[0], 'app', 'views', 'notification_mailer')
        #     expect(workspaceElement.querySelectorAll('.select-list li').length).toBe fs.readdirSync(viewDir).length
        #     for view in fs.readdirSync(viewDir)
        #       expect($(workspaceElement).find(".select-list .primary-line:contains(#{view})")).toExist()
        #       expect($(workspaceElement).find(".select-list .secondary-line:contains(#{atom.project.relativize(path.join(viewDir, view))})")).toExist()
        # 
        #     expect($(workspaceElement).find(".select-list li:first")).toHaveClass 'two-lines selected'
        #     # hide view-finder for next test
        #     atom.commands.dispatch workspaceElement, 'rails-transporter:open-view-finder'
  
    describe "when active editor opens model", ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(path.join(atom.project.getPaths()[0], 'app', 'models', 'blog.rb'))
    
      describe "when the rails-transporter:open-view-finder event is triggered", ->
        # it "shows the ViewFinder or hides it if it's already showing", ->
        #   expect(workspaceElement.querySelector('.select-list')).not.toExist()
        # 
        #   # This is an activation event, triggering it will cause the package to be
        #   # activated.
        #   atom.commands.dispatch workspaceElement, 'rails-transporter:open-view-finder'
        # 
        #   # Waits until package is activated
        #   waitsForPromise ->
        #     activationPromise
        # 
        #   runs ->
        #     expect(workspaceElement.querySelector('.select-list')).toExist()
        #     atom.commands.dispatch workspaceElement, 'rails-transporter:open-view-finder'
        #     expect(workspaceElement.querySelector('.select-list')).not.toExist()
    
        # it "shows all relative view paths for the current controller and selects the first", ->
        #   atom.commands.dispatch workspaceElement, 'rails-transporter:open-view-finder'
        # 
        #   # Waits until package is activated
        #   waitsForPromise ->
        #     activationPromise
        # 
        #   runs ->
        #     viewDir = path.join(atom.project.getPaths()[0], 'app', 'views', 'blogs')
        #     expect($(workspaceElement).find('.select-list li').length).toBe fs.readdirSync(viewDir).length
        #     for view in fs.readdirSync(viewDir)
        #       expect($(workspaceElement).find(".select-list .primary-line:contains(#{view})")).toExist()
        #       expect($(workspaceElement).find(".select-list .secondary-line:contains(#{atom.project.relativize(path.join(viewDir, view))})")).toExist()
        # 
        #     expect($(workspaceElement).find(".select-list li:first")).toHaveClass 'two-lines selected'
  
  describe "open-model behavior", ->
    describe "when active editor opens model and cursor is on include method", ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(path.join(atom.project.getPaths()[0], 'app', 'models', 'blog.rb'))
      
      it "opens model concern", ->
        editor = atom.workspace.getActiveTextEditor()
        editor.setCursorBufferPosition new Point(1, 0)
        atom.commands.dispatch workspaceElement, 'rails-transporter:open-model'

        # Waits until package is activated and active panes count is 2
        waitsFor ->
          activationPromise
          atom.workspace.getActivePane().getItems().length == 2

        runs ->
          concernPath = path.join(atom.project.getPaths()[0], 'app', 'models', 'concerns', 'searchable.rb')
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(0, 0)
          expect(editor.getPath()).toBe concernPath
          expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^module Searchable$/
      
    describe "when active editor opens controller", ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(path.join(atom.project.getPaths()[0], 'app', 'controllers', 'blogs_controller.rb'))
    
      it "opens related model", ->
        atom.commands.dispatch workspaceElement, 'rails-transporter:open-model'
    
        # Waits until package is activated and active panes count is 2
        waitsFor ->
          activationPromise
          atom.workspace.getActivePane().getItems().length == 2
    
        runs ->
          modelPath = path.join(atom.project.getPaths()[0], 'app', 'models', 'blog.rb')
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(0, 0)
          expect(editor.getPath()).toBe modelPath
          expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^class Blog < ActiveRecord::Base$/
            
    describe "when active editor opens namespaced controller", ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(path.join(atom.project.getPaths()[0], 'app', 'controllers', 'admins', 'blogs_controller.rb'))
    
      it "opens related model", ->
        atom.commands.dispatch workspaceElement, 'rails-transporter:open-model'
    
        # Waits until package is activated and active panes count is 2
        waitsFor ->
          activationPromise
          atom.workspace.getActivePane().getItems().length == 2
    
        runs ->
          modelPath = path.join(atom.project.getPaths()[0], 'app', 'models', 'blog.rb')
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(0, 0)
          expect(editor.getPath()).toBe modelPath
          expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^class Blog < ActiveRecord::Base$/

            
   describe "when active editor opens model test", ->
     beforeEach ->
       waitsForPromise ->
         atom.workspace.open(path.join(atom.project.getPaths()[0], 'test', 'models', 'blog_test.rb'))
   
     it "opens related model", ->
       atom.commands.dispatch workspaceElement, 'rails-transporter:open-model'
   
       # Waits until package is activated and active panes count is 2
       waitsFor ->
         activationPromise
         atom.workspace.getActivePane().getItems().length == 2
   
       runs ->
         modelPath = path.join(atom.project.getPaths()[0], 'app', 'models', 'blog.rb')
         editor = atom.workspace.getActiveTextEditor()
         editor.setCursorBufferPosition new Point(0, 0)
         expect(editor.getPath()).toBe modelPath
         expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^class Blog < ActiveRecord::Base$/
 
    describe "when active editor opens model spec", ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(path.join(atom.project.getPaths()[0], 'spec', 'models', 'blog_spec.rb'))
    
      it "opens related model", ->
        atom.commands.dispatch workspaceElement, 'rails-transporter:open-model'
    
        # Waits until package is activated and active panes count is 2
        waitsFor ->
          activationPromise
          atom.workspace.getActivePane().getItems().length == 2
    
        runs ->
          modelPath = path.join(atom.project.getPaths()[0], 'app', 'models', 'blog.rb')
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(0, 0)
          expect(editor.getPath()).toBe modelPath
          expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^class Blog < ActiveRecord::Base$/
            
    describe "when active editor opens factory", ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(path.join(atom.project.getPaths()[0], 'spec', 'factories', 'blogs.rb'))
    
      it "opens related model", ->
        atom.commands.dispatch workspaceElement, 'rails-transporter:open-model'
    
        # Waits until package is activated and active panes count is 2
        waitsFor ->
          activationPromise
          atom.workspace.getActivePane().getItems().length == 2
    
        runs ->
          modelPath = path.join(atom.project.getPaths()[0], 'app', 'models', 'blog.rb')
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(0, 0)
          expect(editor.getPath()).toBe modelPath
          expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^class Blog < ActiveRecord::Base$/
    
            
    describe "when active editor opens view", ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(path.join(atom.project.getPaths()[0], 'app', 'views', 'blogs', 'show.html.erb'))
  
      it "opens related model", ->
        atom.commands.dispatch workspaceElement, 'rails-transporter:open-model'
  
        # Waits until package is activated and active panes count is 2
        waitsFor ->
          activationPromise
          atom.workspace.getActivePane().getItems().length == 2
  
        runs ->
          modelPath = path.join(atom.project.getPaths()[0], 'app', 'models', 'blog.rb')
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(0, 0)
          expect(editor.getPath()).toBe modelPath
          expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^class Blog < ActiveRecord::Base$/
  
  describe "open-helper behavior", ->
    describe "when active editor opens controller", ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(path.join(atom.project.getPaths()[0], 'app', 'controllers', 'blogs_controller.rb'))
    
      it "opens related helper", ->
        atom.commands.dispatch workspaceElement, 'rails-transporter:open-helper'
    
        # Waits until package is activated and active panes count is 2
        waitsFor ->
          activationPromise
          atom.workspace.getActivePane().getItems().length == 2
    
        runs ->
          helperPath = path.join(atom.project.getPaths()[0], 'app', 'helpers', 'blogs_helper.rb')
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(0, 0)
          expect(editor.getPath()).toBe helperPath
          expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^module BlogsHelper$/
  
    describe "when active editor opens helper test", ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(path.join(atom.project.getPaths()[0], 'test', 'helpers', 'blogs_helper_test.rb'))
    
      it "opens related helper", ->
        atom.commands.dispatch workspaceElement, 'rails-transporter:open-helper'
    
        # Waits until package is activated and active panes count is 2
        waitsFor ->
          activationPromise
          atom.workspace.getActivePane().getItems().length == 2
    
        runs ->
          helperPath = path.join(atom.project.getPaths()[0], 'app', 'helpers', 'blogs_helper.rb')
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(0, 0)
          expect(editor.getPath()).toBe helperPath
          expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^module BlogsHelper$/

    describe "when active editor opens helper spec", ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(path.join(atom.project.getPaths()[0], 'spec', 'helpers', 'blogs_helper_spec.rb'))
    
      it "opens related helper", ->
        atom.commands.dispatch workspaceElement, 'rails-transporter:open-helper'
    
        # Waits until package is activated and active panes count is 2
        waitsFor ->
          activationPromise
          atom.workspace.getActivePane().getItems().length == 2
    
        runs ->
          helperPath = path.join(atom.project.getPaths()[0], 'app', 'helpers', 'blogs_helper.rb')
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(0, 0)
          expect(editor.getPath()).toBe helperPath
          expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^module BlogsHelper$/
  
    describe "when active editor opens model", ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(path.join(atom.project.getPaths()[0], 'app', 'models', 'blog.rb'))
    
      it "opens related helper", ->
        atom.commands.dispatch workspaceElement, 'rails-transporter:open-helper'
    
        # Waits until package is activated and active panes count is 2
        waitsFor ->
          activationPromise
          atom.workspace.getActivePane().getItems().length == 2
    
        runs ->
          helperPath = path.join(atom.project.getPaths()[0], 'app', 'helpers', 'blogs_helper.rb')
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(0, 0)
          expect(editor.getPath()).toBe helperPath
          expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^module BlogsHelper$/
  
    describe "when active editor opens view", ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(path.join(atom.project.getPaths()[0], 'app', 'views', 'blogs', 'show.html.erb'))
  
      it "opens related helper", ->
        atom.commands.dispatch workspaceElement, 'rails-transporter:open-helper'
  
        # Waits until package is activated and active panes count is 2
        waitsFor ->
          activationPromise
          atom.workspace.getActivePane().getItems().length == 2
  
        runs ->
          helperPath = path.join(atom.project.getPaths()[0], 'app', 'helpers', 'blogs_helper.rb')
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(0, 0)
          expect(editor.getPath()).toBe helperPath
          expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^module BlogsHelper$/
  
  describe "open-patial-template behavior", ->
    beforeEach ->
      waitsForPromise ->
        atom.workspace.open(path.join(atom.project.getPaths()[0], 'app', 'views', 'blogs', 'edit.html.erb'))
  
    describe "when cursor's current buffer row contains render method", ->
      it "opens partial template", ->
        editor = atom.workspace.getActiveTextEditor()
        editor.setCursorBufferPosition new Point(2, 0)
        atom.commands.dispatch workspaceElement, 'rails-transporter:open-partial-template'
  
        # Waits until package is activated and active panes count is 2
        waitsFor ->
          activationPromise
          atom.workspace.getActivePane().getItems().length == 2
  
        runs ->
          partialPath = path.join(atom.project.getPaths()[0], 'app', 'views', 'blogs', '_form.html.erb')
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(0, 0)
          expect(editor.getPath()).toBe partialPath
          expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^Form Partial$/
  
    describe "when cursor's current buffer row contains render method with ':partial =>'", ->
      it "opens partial template", ->
        editor = atom.workspace.getActiveTextEditor()
        editor.setCursorBufferPosition new Point(3, 0)
        atom.commands.dispatch workspaceElement, 'rails-transporter:open-partial-template'
  
        # Waits until package is activated and active panes count is 2
        waitsFor ->
          activationPromise
          atom.workspace.getActivePane().getItems().length == 2
  
        runs ->
          partialPath = path.join(atom.project.getPaths()[0], 'app', 'views', 'blogs', '_form.html.erb')
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(0, 0)
          expect(editor.getPath()).toBe partialPath
          expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^Form Partial$/
  
    describe "when cursor's current buffer row contains render method with 'partial:'", ->
      it "opens partial template", ->
        editor = atom.workspace.getActiveTextEditor()
        editor.setCursorBufferPosition new Point(4, 0)
        atom.commands.dispatch workspaceElement, 'rails-transporter:open-partial-template'
  
        # Waits until package is activated and active panes count is 2
        waitsFor ->
          activationPromise
          atom.workspace.getActivePane().getItems().length == 2
  
        runs ->
          partialPath = path.join(atom.project.getPaths()[0], 'app', 'views', 'blogs', '_form.html.erb')
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(0, 0)
          expect(editor.getPath()).toBe partialPath
          expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^Form Partial$/
  
    describe "when cursor's current buffer row contains render method taking shared partial", ->
      it "opens shared partial template", ->
        editor = atom.workspace.getActiveTextEditor()
        editor.setCursorBufferPosition new Point(5, 0)
        atom.commands.dispatch workspaceElement, 'rails-transporter:open-partial-template'
  
        # Waits until package is activated and active panes count is 2
        waitsFor ->
          activationPromise
          atom.workspace.getActivePane().getItems().length == 2
  
        runs ->
          partialPath = path.join(atom.project.getPaths()[0], 'app', 'views', 'shared', '_form.html.erb')
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(0, 0)
          expect(editor.getPath()).toBe partialPath
          expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^Shared Form Partial$/
  
    describe "when current line is to call render method with integer", ->
      it "opens partial template", ->
        editor = atom.workspace.getActiveTextEditor()
        editor.setCursorBufferPosition new Point(6, 0)
        atom.commands.dispatch workspaceElement, 'rails-transporter:open-partial-template'
  
        # Waits until package is activated and active panes count is 2
        waitsFor ->
          activationPromise
          atom.workspace.getActivePane().getItems().length == 2
  
        runs ->
          partialPath = path.join(atom.project.getPaths()[0], 'app', 'views', 'blogs', '_form02.html.erb')
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(0, 0)
          expect(editor.getPath()).toBe partialPath
          expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^Form02 Partial$/
          
    describe "when current line is to call render method with integer and including ':partial =>'", ->
      it "opens partial template", ->
        editor = atom.workspace.getActiveTextEditor()
        editor.setCursorBufferPosition new Point(7, 0)
        atom.commands.dispatch workspaceElement, 'rails-transporter:open-partial-template'
  
        # Waits until package is activated and active panes count is 2
        waitsFor ->
          activationPromise
          atom.workspace.getActivePane().getItems().length == 2
  
        runs ->
          partialPath = path.join(atom.project.getPaths()[0], 'app', 'views', 'blogs', '_form02.html.erb')
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(0, 0)
          expect(editor.getPath()).toBe partialPath
          expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^Form02 Partial$/
  
    describe "when current line is to call render method with integer and including '(:partial =>'", ->
      it "opens partial template", ->
        editor = atom.workspace.getActiveTextEditor()
        editor.setCursorBufferPosition new Point(8, 0)
        atom.commands.dispatch workspaceElement, 'rails-transporter:open-partial-template'
  
        # Waits until package is activated and active panes count is 2
        waitsFor ->
          activationPromise
          atom.workspace.getActivePane().getItems().length == 2
  
        runs ->
          partialPath = path.join(atom.project.getPaths()[0], 'app', 'views', 'blogs', '_form02.html.erb')
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(0, 0)
          expect(editor.getPath()).toBe partialPath
          expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^Form02 Partial$/
          
    describe "when current line is to call render method with '(", ->
      it "opens partial template", ->
        editor = atom.workspace.getActiveTextEditor()
        editor.setCursorBufferPosition new Point(9, 0)
        atom.commands.dispatch workspaceElement, 'rails-transporter:open-partial-template'
  
        # Waits until package is activated and active panes count is 2
        waitsFor ->
          activationPromise
          atom.workspace.getActivePane().getItems().length == 2
  
        runs ->
          partialPath = path.join(atom.project.getPaths()[0], 'app', 'views', 'blogs', '_form02.html.erb')
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(0, 0)
          expect(editor.getPath()).toBe partialPath
          expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^Form02 Partial$/
  
  describe "open-layout", ->
    describe "when cursor's current buffer row contains layout method", ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(path.join(atom.project.getPaths()[0], 'app', 'controllers', 'blogs_controller.rb'))
  
      it "opens specified layout", ->
        editor = atom.workspace.getActiveTextEditor()
        editor.setCursorBufferPosition new Point(2, 0)
        atom.commands.dispatch workspaceElement, 'rails-transporter:open-layout'
  
        # Waits until package is activated and active panes count is 2
        waitsFor ->
          activationPromise
          atom.workspace.getActivePane().getItems().length == 2
  
        runs ->
          partialPath = path.join(atom.project.getPaths()[0], 'app', 'views', 'layouts', 'special.html.erb')
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(3, 0)
          expect(editor.getPath()).toBe partialPath
          expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /Special Layout/
          
    describe "when same base name as the controller exists", ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(path.join(atom.project.getPaths()[0], 'app', 'controllers', 'top_controller.rb'))
  
      it "opens layout that same base name as the controller", ->
        editor = atom.workspace.getActiveTextEditor()
        atom.commands.dispatch workspaceElement, 'rails-transporter:open-layout'
  
        # Waits until package is activated and active panes count is 2
        waitsFor ->
          activationPromise
          atom.workspace.getActivePane().getItems().length == 2
  
        runs ->
          partialPath = path.join(atom.project.getPaths()[0], 'app', 'views', 'layouts', 'top.html.erb')
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(3, 0)
          expect(editor.getPath()).toBe partialPath
          expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /Top Layout/
          
    describe "when there is no such controller-specific layout", ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(path.join(atom.project.getPaths()[0], 'app', 'controllers', 'main_controller.rb'))
  
      it "opens default layout named 'application'", ->
        editor = atom.workspace.getActiveTextEditor()
        atom.commands.dispatch workspaceElement, 'rails-transporter:open-layout'
  
        # Waits until package is activated and active panes count is 2
        waitsFor ->
          activationPromise
          atom.workspace.getActivePane().getItems().length == 2
  
        runs ->
          partialPath = path.join(atom.project.getPaths()[0], 'app', 'views', 'layouts', 'application.html.erb')
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(3, 0)
          expect(editor.getPath()).toBe partialPath
          expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /Application Layout/
  
  
  describe "open-spec behavior", ->
    describe "when active editor opens controller", ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(path.join(atom.project.getPaths()[0], 'app', 'controllers', 'blogs_controller.rb'))
  
      it "opens controller spec", ->
        atom.commands.dispatch workspaceElement, 'rails-transporter:open-spec'
  
        waitsFor ->
          activationPromise
          atom.workspace.getActivePane().getItems().length == 2
          
        runs ->
          specPath = path.join(atom.project.getPaths()[0], 'spec', 'controllers', 'blogs_controller_spec.rb')
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(20, 0)
          expect(editor.getPath()).toBe specPath
          expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^describe BlogsController/
      
    describe "when active editor opens model", ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(path.join(atom.project.getPaths()[0], 'app', 'models', 'blog.rb'))
  
      it "opens model spec", ->
        atom.commands.dispatch workspaceElement, 'rails-transporter:open-spec'
  
        waitsFor ->
          activationPromise
          atom.workspace.getActivePane().getItems().length == 2
          
        runs ->
          specPath = path.join(atom.project.getPaths()[0], 'spec', 'models', 'blog_spec.rb')
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(2, 0)
          expect(editor.getPath()).toBe specPath
          expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^describe Blog /
          
    describe "when active editor opens factory", ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(path.join(atom.project.getPaths()[0], 'spec', 'factories', 'blogs.rb'))
  
      it "opens model spec", ->
        atom.commands.dispatch workspaceElement, 'rails-transporter:open-spec'
  
        waitsFor ->
          activationPromise
          atom.workspace.getActivePane().getItems().length == 2
          
        runs ->
          specPath = path.join(atom.project.getPaths()[0], 'spec', 'models', 'blog_spec.rb')
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(2, 0)
          expect(editor.getPath()).toBe specPath
          expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^describe Blog /
    
    describe "when active editor opens helper", ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(path.join(atom.project.getPaths()[0], 'app', 'helpers', 'blogs_helper.rb'))
  
      it "opens helper spec", ->
        atom.commands.dispatch workspaceElement, 'rails-transporter:open-spec'
  
        waitsFor ->
          activationPromise
          atom.workspace.getActivePane().getItems().length == 2
          
        runs ->
          specPath = path.join(atom.project.getPaths()[0], 'spec', 'helpers', 'blogs_helper_spec.rb')
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(12, 0)
          expect(editor.getPath()).toBe specPath
          expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^describe BlogsHelper/
  
  describe "open-test behavior", ->
    describe "when active editor opens controller", ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(path.join(atom.project.getPaths()[0], 'app', 'controllers', 'blogs_controller.rb'))
    
      it "opens controller test", ->
        atom.commands.dispatch workspaceElement, 'rails-transporter:open-test'
    
        waitsFor ->
          activationPromise
          atom.workspace.getActivePane().getItems().length == 2
          
        runs ->
          testPath = path.join(atom.project.getPaths()[0], 'test', 'controllers', 'blogs_controller_test.rb')
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(2, 0)
          expect(editor.getPath()).toBe testPath
          expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^describe BlogsController/
      
    describe "when active editor opens model", ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(path.join(atom.project.getPaths()[0], 'app', 'models', 'blog.rb'))
    
      it "opens model test", ->
        atom.commands.dispatch workspaceElement, 'rails-transporter:open-test'
    
        waitsFor ->
          activationPromise
          atom.workspace.getActivePane().getItems().length == 2
          
        runs ->
          testPath = path.join(atom.project.getPaths()[0], 'test', 'models', 'blog_test.rb')
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(2, 0)
          expect(editor.getPath()).toBe testPath
          expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^describe Blog /
          
    describe "when active editor opens helper", ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(path.join(atom.project.getPaths()[0], 'app', 'helpers', 'blogs_helper.rb'))
    
      it "opens helper test", ->
        atom.commands.dispatch workspaceElement, 'rails-transporter:open-test'
    
        waitsFor ->
          activationPromise
          atom.workspace.getActivePane().getItems().length == 2
          
        runs ->
          testPath = path.join(atom.project.getPaths()[0], 'test', 'helpers', 'blogs_helper_test.rb')
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(2, 0)
          expect(editor.getPath()).toBe testPath
          expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^describe BlogsHelper/
  
  describe "open-asset behavior",  ->
    describe "when active editor opens view", ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(path.join(atom.project.getPaths()[0], 'app', 'views', 'layouts', 'application.html.erb'))
  
      describe "when cursor's current buffer row contains stylesheet_link_tag", ->
        describe "enclosed in parentheses", ->
          it "opens stylesheet", ->
            editor = atom.workspace.getActiveTextEditor()
            editor.setCursorBufferPosition new Point(10, 0)
            atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
  
            waitsFor ->
              activationPromise
              atom.workspace.getActivePane().getItems().length == 2
  
            runs ->
              assetPath = path.join(atom.project.getPaths()[0], 'app', 'assets', 'stylesheets', 'application.css')
              editor = atom.workspace.getActiveTextEditor()
              editor.setCursorBufferPosition new Point(10, 0)
              expect(editor.getPath()).toBe assetPath
              expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /require_self$/
  
        describe "unenclosed in parentheses", ->
          it "opens stylesheet", ->
            editor = atom.workspace.getActiveTextEditor()
            editor.setCursorBufferPosition new Point(11, 0)
            atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
        
            waitsFor ->
              activationPromise
              atom.workspace.getActivePane().getItems().length == 2
        
            runs ->
              assetPath = path.join(atom.project.getPaths()[0], 'app', 'assets', 'stylesheets', 'application.css')
              editor = atom.workspace.getActiveTextEditor()
              editor.setCursorBufferPosition new Point(11, 0)
              expect(editor.getPath()).toBe assetPath
              expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /require_tree/
        
        describe "when source includes slash", ->
          it "opens stylesheet", ->
            editor = atom.workspace.getActiveTextEditor()
            editor.setCursorBufferPosition new Point(12, 0)
            atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
        
            waitsFor ->
              activationPromise
              atom.workspace.getActivePane().getItems().length == 2
        
            runs ->
              assetPath = path.join(atom.project.getPaths()[0], 'app', 'assets', 'stylesheets', 'application02', 'common.css')
              editor = atom.workspace.getActiveTextEditor()
              editor.setCursorBufferPosition new Point(1, 0)
              expect(editor.getPath()).toBe assetPath
              expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /require_self/
        
        describe "when source is located in vendor directory", ->
          it "opens stylesheet in vendor directory", ->
            editor = atom.workspace.getActiveTextEditor()
            editor.setCursorBufferPosition new Point(13, 0)
            atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
        
            waitsFor ->
              activationPromise
              atom.workspace.getActivePane().getItems().length == 2
        
            runs ->
              assetPath = path.join(atom.project.getPaths()[0], 'vendor', 'assets', 'stylesheets', 'jquery.popular_style.css.scss')
              editor = atom.workspace.getActiveTextEditor()
              editor.setCursorBufferPosition new Point(0, 0)
              expect(editor.getPath()).toBe assetPath
              expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /it's popular scss file$/
        
        describe "when source is located in lib directory", ->
          it "opens stylesheet in lib directory", ->
            editor = atom.workspace.getActiveTextEditor()
            editor.setCursorBufferPosition new Point(16, 0)
            atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
  
            waitsFor ->
              activationPromise
              atom.workspace.getActivePane().getItems().length == 2
  
            runs ->
              assetPath = path.join(atom.project.getPaths()[0], 'lib', 'assets', 'stylesheets', 'my_style.css.scss')
              editor = atom.workspace.getActiveTextEditor()
              editor.setCursorBufferPosition new Point(0, 0)
              expect(editor.getPath()).toBe assetPath
              expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /it's my scss file$/
  
        describe "when source is located in public directory", ->
          it "opens stylesheet in public directory", ->
            editor = atom.workspace.getActiveTextEditor()
            editor.setCursorBufferPosition new Point(14, 0)
            atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
        
            waitsFor ->
              activationPromise
              atom.workspace.getActivePane().getItems().length == 2
        
            runs ->
              assetPath = path.join(atom.project.getPaths()[0], 'public', 'no_asset_pipeline.css')
              editor = atom.workspace.getActiveTextEditor()
              editor.setCursorBufferPosition new Point(0, 0)
              expect(editor.getPath()).toBe assetPath
              expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^\/\/ it's css in public directory$/
            
      describe "when cursor's current buffer row contains javascript_include_tag", ->
        describe "enclosed in parentheses", ->
          it "opens javascript", ->
            editor = atom.workspace.getActiveTextEditor()
            editor.setCursorBufferPosition new Point(5, 0)
            atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
  
            waitsFor ->
              activationPromise
              atom.workspace.getActivePane().getItems().length == 2
  
            runs ->
              assetPath = path.join(atom.project.getPaths()[0], 'app', 'assets', 'javascripts', 'application01.js')
              editor = atom.workspace.getActiveTextEditor()
              editor.setCursorBufferPosition new Point(12, 0)
              expect(editor.getPath()).toBe assetPath
              expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^\/\/= require jquery$/
      
        describe "unenclosed in parentheses", ->
          it "opens javascript", ->
            editor = atom.workspace.getActiveTextEditor()
            editor.setCursorBufferPosition new Point(6, 0)
            atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
  
            waitsFor ->
              activationPromise
              atom.workspace.getActivePane().getItems().length == 2
  
            runs ->
              assetPath = path.join(atom.project.getPaths()[0], 'app', 'assets', 'javascripts', 'application01.js')
              editor = atom.workspace.getActiveTextEditor()
              editor.setCursorBufferPosition new Point(12, 0)
              expect(editor.getPath()).toBe assetPath
              expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^\/\/= require jquery$/
  
        describe "when source includes slash", ->
          it "opens javascript in another directory", ->
            editor = atom.workspace.getActiveTextEditor()
            editor.setCursorBufferPosition new Point(7, 0)
            atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
  
            waitsFor ->
              activationPromise
              atom.workspace.getActivePane().getItems().length == 2
  
            runs ->
              assetPath = path.join(atom.project.getPaths()[0], 'app', 'assets', 'javascripts', 'application02', 'common.js')
              editor = atom.workspace.getActiveTextEditor()
              editor.setCursorBufferPosition new Point(0, 0)
              expect(editor.getPath()).toBe assetPath
              expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^\/\/= require jquery$/
              
        describe "when source is located in vendor directory", ->
          it "opens javascript in vendor directory", ->
            editor = atom.workspace.getActiveTextEditor()
            editor.setCursorBufferPosition new Point(8, 0)
            atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
  
            waitsFor ->
              activationPromise
              atom.workspace.getActivePane().getItems().length == 2
  
            runs ->
              assetPath = path.join(atom.project.getPaths()[0], 'vendor', 'assets', 'javascripts', 'jquery.popular_library.js')
              editor = atom.workspace.getActiveTextEditor()
              editor.setCursorBufferPosition new Point(0, 0)
              expect(editor.getPath()).toBe assetPath
              expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^\/\/ it's popular library$/
  
        describe "when source is located in lib directory", ->
          it "opens javascript in lib directory", ->
            editor = atom.workspace.getActiveTextEditor()
            editor.setCursorBufferPosition new Point(15, 0)
            atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
  
            waitsFor ->
              activationPromise
              atom.workspace.getActivePane().getItems().length == 2
  
            runs ->
              assetPath = path.join(atom.project.getPaths()[0], 'lib', 'assets', 'javascripts', 'my_library.js')
              editor = atom.workspace.getActiveTextEditor()
              editor.setCursorBufferPosition new Point(0, 0)
              expect(editor.getPath()).toBe assetPath
              expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^\/\/ it's my library$/
  
        describe "when source is located in public directory", ->
          it "opens javascript in public directory", ->
            editor = atom.workspace.getActiveTextEditor()
            editor.setCursorBufferPosition new Point(9, 0)
            atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
  
            waitsFor ->
              activationPromise
              atom.workspace.getActivePane().getItems().length == 2
  
            runs ->
              assetPath = path.join(atom.project.getPaths()[0], 'public', 'no_asset_pipeline.js')
              editor = atom.workspace.getActiveTextEditor()
              editor.setCursorBufferPosition new Point(0, 0)
              expect(editor.getPath()).toBe assetPath
              expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^\/\/ it's in public directory$/
            
        describe "when source's suffix is .erb", ->
          it "opens .erb javascript", ->
            editor = atom.workspace.getActiveTextEditor()
            editor.setCursorBufferPosition new Point(17, 0)
            atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
  
            waitsFor ->
              activationPromise
              atom.workspace.getActivePane().getItems().length == 2
  
            runs ->
              assetPath = path.join(atom.project.getPaths()[0], 'app', 'assets', 'javascripts', 'dynamic_script.js.coffee.erb')
              editor = atom.workspace.getActiveTextEditor()
              editor.setCursorBufferPosition new Point(0, 0)
              expect(editor.getPath()).toBe assetPath
              expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^# \.erb file$/
  
    describe "when active editor opens javascript manifest", ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(path.join(atom.project.getPaths()[0], 'app', 'assets', 'javascripts', 'application01.js'))
        
      describe "cursor's current buffer row contains require_tree", ->
        beforeEach ->
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(15, 0)
  
        # it "shows the AssetFinder or hides it if it's already showing", ->
        #   expect(workspaceElement.querySelector('.select-list')).not.toExist()
        # 
        #   # This is an activation event, triggering it will cause the package to be
        #   # activated.
        #   atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
        # 
        #   # Waits until package is activated
        #   waitsForPromise ->
        #     activationPromise
        # 
        #   runs ->
        #     expect(workspaceElement.querySelector('.select-list')).toExist()
        #     atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
        #     expect(workspaceElement.querySelector('.select-list')).not.toExist()
      
        it "shows file paths in required directory and its subdirectories and selects the first", ->
          atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
      
          # Waits until package is activated
          waitsForPromise ->
            activationPromise
      
          runs ->
            requireDir = path.join(atom.project.getPaths()[0], 'app', 'assets', 'javascripts', 'shared')
            expect(workspaceElement.querySelectorAll('.select-list li').length).toBe fs.readdirSync(requireDir).length
            # file be located directly below
            expect($(workspaceElement).find(".select-list .primary-line:contains(common.js.coffee)")).toExist()
            expect($(workspaceElement).find(".select-list .secondary-line:contains(#{atom.project.relativize(path.join(requireDir, 'common.js.coffee'))})")).toExist()
            # file be located subdirectory
            expect($(workspaceElement).find(".select-list .primary-line:contains(subdir.js.coffee)")).toExist()
            expect($(workspaceElement).find(".select-list .secondary-line:contains(#{atom.project.relativize(path.join(requireDir, 'subdir', 'subdir.js.coffee'))})")).toExist()
      
            expect($(workspaceElement).find(".select-list li:first")).toHaveClass 'two-lines selected'
            # hide finder
            atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
  
      describe "cursor's current buffer row contains require_directory", ->
        beforeEach ->
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(24, 0)
      
        # it "shows the AssetFinder or hides it if it's already showing", ->
        #   expect(workspaceElement.querySelector('.select-list')).not.toExist()
        # 
        #   # This is an activation event, triggering it will cause the package to be
        #   # activated.
        #   atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
        # 
        #   # Waits until package is activated
        #   waitsForPromise ->
        #     activationPromise
        # 
        #   runs ->
        #     expect(workspaceElement.querySelector('.select-list')).toExist()
        #     atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
        #     expect(workspaceElement.querySelector('.select-list')).not.toExist()
      
        # it "shows file paths in required directory and selects the first", ->
        #   atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
        # 
        #   # Waits until package is activated
        #   waitsForPromise ->
        #     activationPromise
        # 
        #   runs ->
        #     requireDir = path.join(atom.project.getPaths()[0], 'app', 'assets', 'javascripts', 'shared')
        #     filesInDirectory = (file for file in fs.readdirSync(requireDir) when fs.lstatSync(path.join(requireDir, file)).isFile())
        #     
        #     expect(workspaceElement.querySelectorAll('.select-list li').length).toBe filesInDirectory.length
        #     for file in filesInDirectory
        #       # file be located directly below
        #       expect($(workspaceElement).find(".select-list .primary-line:contains(#{file})")).toExist()
        #       expect($(workspaceElement).find(".select-list .secondary-line:contains(#{atom.project.relativize(path.join(requireDir, file))})")).toExist()
        # 
        #     # expect(workspaceElement.querySelector('.select-list li').length).toBe
        #     expect($(workspaceElement).find(".select-list li:first")).toHaveClass 'two-lines selected'
        
      describe "cursor's current buffer row contains require", ->
        describe "when it requires coffeescript with .js suffix", ->
          it "opens coffeescript", ->
            editor = atom.workspace.getActiveTextEditor()
            editor.setCursorBufferPosition new Point(22, 0)
            atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
          
            waitsFor ->
              activationPromise
              atom.workspace.getActivePane().getItems().length == 2
          
            runs ->
              assetPath = path.join(atom.project.getPaths()[0], 'app', 'assets', 'javascripts', 'blogs.js.coffee')
              editor = atom.workspace.getActiveTextEditor()
              editor.setCursorBufferPosition new Point(0, 0)
              expect(editor.getPath()).toBe assetPath
              expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^# blogs js$/
  
        describe "when it requires coffeescript with .js.coffee suffix", ->
          it "opens coffeescript", ->
            editor = atom.workspace.getActiveTextEditor()
            editor.setCursorBufferPosition new Point(23, 0)
            atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
  
            waitsFor ->
              activationPromise
              atom.workspace.getActivePane().getItems().length == 2
  
            runs ->
              assetPath = path.join(atom.project.getPaths()[0], 'app', 'assets', 'javascripts', 'blogs.js.coffee')
              editor = atom.workspace.getActiveTextEditor()
              editor.setCursorBufferPosition new Point(0, 0)
              expect(editor.getPath()).toBe assetPath
              expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^# blogs js$/
  
        describe "when it requires coffeescript without suffix", ->
          it "opens coffeescript", ->
            editor = atom.workspace.getActiveTextEditor()
            editor.setCursorBufferPosition new Point(16, 0)
            atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
        
            waitsFor ->
              activationPromise
              atom.workspace.getActivePane().getItems().length == 2
        
            runs ->
              assetPath = path.join(atom.project.getPaths()[0], 'app', 'assets', 'javascripts', 'blogs.js.coffee')
              editor = atom.workspace.getActiveTextEditor()
              editor.setCursorBufferPosition new Point(0, 0)
              expect(editor.getPath()).toBe assetPath
              expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^# blogs js$/
              
        describe "when it requires javascript without suffix", ->
          it "opens javascript", ->
            editor = atom.workspace.getActiveTextEditor()
            editor.setCursorBufferPosition new Point(17, 0)
            atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
  
            waitsFor ->
              activationPromise
              atom.workspace.getActivePane().getItems().length == 2
  
            runs ->
              assetPath = path.join(atom.project.getPaths()[0], 'app', 'assets', 'javascripts', 'pure-js-blogs.js')
              editor = atom.workspace.getActiveTextEditor()
              editor.setCursorBufferPosition new Point(0, 0)
              expect(editor.getPath()).toBe assetPath
              expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^# pure blogs js$/
              
        describe "when it requires coffeescript in another directory", ->
          it "opens coffeescript in another directory", ->
            editor = atom.workspace.getActiveTextEditor()
            editor.setCursorBufferPosition new Point(18, 0)
            atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
  
            waitsFor ->
              activationPromise
              atom.workspace.getActivePane().getItems().length == 2
  
            runs ->
              assetPath = path.join(atom.project.getPaths()[0], 'app', 'assets', 'javascripts', 'shared', 'common.js.coffee')
              editor = atom.workspace.getActiveTextEditor()
              editor.setCursorBufferPosition new Point(0, 0)
              expect(editor.getPath()).toBe assetPath
              expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^# shared coffee$/
              
        describe "when it requires javascript in another directory", ->
          it "opens javascript in another directory", ->
            editor = atom.workspace.getActiveTextEditor()
            editor.setCursorBufferPosition new Point(19, 0)
            atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
  
            waitsFor ->
              activationPromise
              atom.workspace.getActivePane().getItems().length == 2
  
            runs ->
              assetPath = path.join(atom.project.getPaths()[0], 'app', 'assets', 'javascripts', 'shared', 'pure-js-common.js')
              editor = atom.workspace.getActiveTextEditor()
              editor.setCursorBufferPosition new Point(0, 0)
              expect(editor.getPath()).toBe assetPath
              expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^# shared js$/
              
        describe "when it requires javascript in lib directory", ->
          it "opens javascript in lib directory", ->
            editor = atom.workspace.getActiveTextEditor()
            editor.setCursorBufferPosition new Point(20, 0)
            atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
  
            waitsFor ->
              activationPromise
              atom.workspace.getActivePane().getItems().length == 2
  
            runs ->
              assetPath = path.join(atom.project.getPaths()[0], 'lib', 'assets', 'javascripts', 'my_library.js')
              editor = atom.workspace.getActiveTextEditor()
              editor.setCursorBufferPosition new Point(0, 0)
              expect(editor.getPath()).toBe assetPath
              expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^\/\/ it's my library$/
  
        describe "when it requires javascript in vendor directory", ->
          it "opens javascript in vendor directory", ->
            editor = atom.workspace.getActiveTextEditor()
            editor.setCursorBufferPosition new Point(21, 0)
            atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
  
            waitsFor ->
              activationPromise
              atom.workspace.getActivePane().getItems().length == 2
  
            runs ->
              assetPath = path.join(atom.project.getPaths()[0], 'vendor', 'assets', 'javascripts', 'jquery.popular_library.js')
              editor = atom.workspace.getActiveTextEditor()
              editor.setCursorBufferPosition new Point(0, 0)
              expect(editor.getPath()).toBe assetPath
              expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^\/\/ it's popular library$/
  
    describe "when active editor opens stylesheet manifest", ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(path.join(atom.project.getPaths()[0], 'app', 'assets', 'stylesheets', 'application.css'))
      
      describe "when cursor's current buffer row contains 'require'", ->
        describe "when it requires scss with .css suffix", ->
          it "opens scss", ->
            editor = atom.workspace.getActiveTextEditor()
            editor.setCursorBufferPosition new Point(12, 0)
            atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
        
            waitsFor ->
              activationPromise
              atom.workspace.getActivePane().getItems().length == 2
        
            runs ->
              assetPath = path.join(atom.project.getPaths()[0], 'app', 'assets', 'stylesheets', 'blogs.css.scss')
              editor = atom.workspace.getActiveTextEditor()
              editor.setCursorBufferPosition new Point(0, 0)
              expect(editor.getPath()).toBe assetPath
              expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^\/\/ it's blogs.css$/
  
        describe "when it requires scss with .css.scss suffix", ->
          it "opens scss", ->
            editor = atom.workspace.getActiveTextEditor()
            editor.setCursorBufferPosition new Point(13, 0)
            atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
        
            waitsFor ->
              activationPromise
              atom.workspace.getActivePane().getItems().length == 2
        
            runs ->
              assetPath = path.join(atom.project.getPaths()[0], 'app', 'assets', 'stylesheets', 'blogs.css.scss')
              editor = atom.workspace.getActiveTextEditor()
              editor.setCursorBufferPosition new Point(0, 0)
              expect(editor.getPath()).toBe assetPath
              expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^\/\/ it's blogs.css$/
        
        describe "when it requires css without suffix", ->
          it "opens css", ->
            editor = atom.workspace.getActiveTextEditor()
            editor.setCursorBufferPosition new Point(14, 0)
            atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
        
            waitsFor ->
              activationPromise
              atom.workspace.getActivePane().getItems().length == 2
        
            runs ->
              assetPath = path.join(atom.project.getPaths()[0], 'app', 'assets', 'stylesheets', 'pure-css-blogs.css')
              editor = atom.workspace.getActiveTextEditor()
              editor.setCursorBufferPosition new Point(0, 0)
              expect(editor.getPath()).toBe assetPath
              expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^\/\/ it's pure css$/
        
        describe "when it requires scss without suffix", ->
          it "opens scss", ->
            editor = atom.workspace.getActiveTextEditor()
            editor.setCursorBufferPosition new Point(15, 0)
            atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
        
            waitsFor ->
              activationPromise
              atom.workspace.getActivePane().getItems().length == 2
        
            runs ->
              assetPath = path.join(atom.project.getPaths()[0], 'app', 'assets', 'stylesheets', 'blogs.css.scss')
              editor = atom.workspace.getActiveTextEditor()
              editor.setCursorBufferPosition new Point(0, 0)
              expect(editor.getPath()).toBe assetPath
              expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^\/\/ it's blogs.css$/
        
        describe "when it requires scss in another directory", ->
          it "opens scss in another directory", ->
            editor = atom.workspace.getActiveTextEditor()
            editor.setCursorBufferPosition new Point(16, 0)
            atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
        
            waitsFor ->
              activationPromise
              atom.workspace.getActivePane().getItems().length == 2
        
            runs ->
              assetPath = path.join(atom.project.getPaths()[0], 'app', 'assets', 'stylesheets', 'shared', 'pure-css-common.css')
              editor = atom.workspace.getActiveTextEditor()
              editor.setCursorBufferPosition new Point(0, 0)
              expect(editor.getPath()).toBe assetPath
              expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^\/\/ it's pure css$/
        
        describe "when it requires css in another directory", ->
          it "opens css in another directory", ->
            editor = atom.workspace.getActiveTextEditor()
            editor.setCursorBufferPosition new Point(17, 0)
            atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
        
            waitsFor ->
              activationPromise
              atom.workspace.getActivePane().getItems().length == 2
        
            runs ->
              assetPath = path.join(atom.project.getPaths()[0], 'app', 'assets', 'stylesheets', 'shared', 'common.css.scss')
              editor = atom.workspace.getActiveTextEditor()
              editor.setCursorBufferPosition new Point(0, 0)
              expect(editor.getPath()).toBe assetPath
              expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^\/\/ it's scss$/
        
        describe "when it requires scss in lib directory", ->
          it "opens scss in lib directory", ->
            editor = atom.workspace.getActiveTextEditor()
            editor.setCursorBufferPosition new Point(18, 0)
            atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
        
            waitsFor ->
              activationPromise
              atom.workspace.getActivePane().getItems().length == 2
        
            runs ->
              assetPath = path.join(atom.project.getPaths()[0], 'lib', 'assets', 'stylesheets', 'my_style.css.scss')
              editor = atom.workspace.getActiveTextEditor()
              editor.setCursorBufferPosition new Point(0, 0)
              expect(editor.getPath()).toBe assetPath
              expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^\/\/ it's my scss file$/
        
        describe "when it requires css in lib directory", ->
          it "opens css in lib directory", ->
            editor = atom.workspace.getActiveTextEditor()
            editor.setCursorBufferPosition new Point(19, 0)
            atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
        
            waitsFor ->
              activationPromise
              atom.workspace.getActivePane().getItems().length == 2
        
            runs ->
              assetPath = path.join(atom.project.getPaths()[0], 'lib', 'assets', 'stylesheets', 'pure_css_my_style.css')
              editor = atom.workspace.getActiveTextEditor()
              editor.setCursorBufferPosition new Point(0, 0)
              expect(editor.getPath()).toBe assetPath
              expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^\/\/ it's my css file$/
  
        describe "when it requires scss in vendor directory", ->
          it "opens scss in vendor directory", ->
            editor = atom.workspace.getActiveTextEditor()
            editor.setCursorBufferPosition new Point(20, 0)
            atom.commands.dispatch workspaceElement, 'rails-transporter:open-asset'
        
            waitsFor ->
              activationPromise
              atom.workspace.getActivePane().getItems().length == 2
        
            runs ->
              assetPath = path.join(atom.project.getPaths()[0], 'vendor', 'assets', 'stylesheets', 'jquery.popular_style.css.scss')
              editor = atom.workspace.getActiveTextEditor()
              editor.setCursorBufferPosition new Point(0, 0)
              expect(editor.getPath()).toBe assetPath
              expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^\/\/ it's popular scss file$/
  
  describe "open-controller behavior", ->
    describe "when active editor opens controller and cursor is on include method", ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(path.join(atom.project.getPaths()[0], 'app', 'controllers', 'blogs_controller.rb'))
      
      it "opens model concern", ->
        editor = atom.workspace.getActiveTextEditor()
        editor.setCursorBufferPosition new Point(3, 0)
        atom.commands.dispatch workspaceElement, 'rails-transporter:open-controller'

        # Waits until package is activated and active panes count is 2
        waitsFor ->
          activationPromise
          atom.workspace.getActivePane().getItems().length == 2

        runs ->
          concernPath = path.join(atom.project.getPaths()[0], 'app', 'controllers', 'concerns', 'blog', 'taggable.rb')
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(0, 0)
          expect(editor.getPath()).toBe concernPath
          expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^module Blog::Taggable$/
  
    describe "when active editor opens model", ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(path.join(atom.project.getPaths()[0], 'app/models/blog.rb'))
    
      it "opens related controller", ->
        atom.commands.dispatch workspaceElement, 'rails-transporter:open-controller'
    
        # Waits until package is activated and active panes count is 2
        waitsFor ->
          activationPromise
          atom.workspace.getActivePane().getItems().length == 2
    
        runs ->
          modelPath = path.join(atom.project.getPaths()[0], 'app', 'controllers', 'blogs_controller.rb')
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(0, 0)
          expect(editor.getPath()).toBe modelPath
          expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^class BlogsController < ApplicationController$/
  
    describe "when active editor opens controller test", ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(path.join(atom.project.getPaths()[0], 'test', 'controllers', 'blogs_controller_test.rb'))
    
      it "opens related controller", ->
        atom.commands.dispatch workspaceElement, 'rails-transporter:open-controller'
    
        # Waits until package is activated and active panes count is 2
        waitsFor ->
          activationPromise
          atom.workspace.getActivePane().getItems().length == 2
    
        runs ->
          modelPath = path.join(atom.project.getPaths()[0], 'app', 'controllers', 'blogs_controller.rb')
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(0, 0)
          expect(editor.getPath()).toBe modelPath
          expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^class BlogsController < ApplicationController$/

    describe "when active editor opens controller spec", ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(path.join(atom.project.getPaths()[0], 'spec', 'controllers', 'blogs_controller_spec.rb'))
    
      it "opens related controller", ->
        atom.commands.dispatch workspaceElement, 'rails-transporter:open-controller'
    
        # Waits until package is activated and active panes count is 2
        waitsFor ->
          activationPromise
          atom.workspace.getActivePane().getItems().length == 2
    
        runs ->
          modelPath = path.join(atom.project.getPaths()[0], 'app', 'controllers', 'blogs_controller.rb')
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(0, 0)
          expect(editor.getPath()).toBe modelPath
          expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^class BlogsController < ApplicationController$/
            
    describe "when active editor opens request spec", ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(path.join(atom.project.getPaths()[0], 'spec', 'requests', 'blogs_spec.rb'))
    
      it "opens related controller", ->
        atom.commands.dispatch workspaceElement, 'rails-transporter:open-controller'
    
        # Waits until package is activated and active panes count is 2
        waitsFor ->
          activationPromise
          atom.workspace.getActivePane().getItems().length == 2
    
        runs ->
          modelPath = path.join(atom.project.getPaths()[0], 'app', 'controllers', 'blogs_controller.rb')
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(0, 0)
          expect(editor.getPath()).toBe modelPath
          expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^class BlogsController < ApplicationController$/
            
    describe "when active editor opens view", ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(path.join(atom.project.getPaths()[0], 'app', 'views', 'blogs', 'show.html.haml'))
    
      it "opens related controller", ->
        atom.commands.dispatch workspaceElement, 'rails-transporter:open-controller'
    
        # Waits until package is activated and active panes count is 2
        waitsFor ->
          activationPromise
          atom.workspace.getActivePane().getItems().length == 2
    
        runs ->
          modelPath = path.join(atom.project.getPaths()[0], 'app', 'controllers', 'blogs_controller.rb')
          editor = atom.workspace.getActiveTextEditor()
          editor.setCursorBufferPosition new Point(0, 0)
          expect(editor.getPath()).toBe modelPath
          expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^class BlogsController < ApplicationController$/

  describe "open-factory behavior", ->
    describe "when active editor opens model", ->
      describe "open plural resource filename", ->
        beforeEach ->
          waitsForPromise ->
            atom.workspace.open(path.join(atom.project.getPaths()[0], 'app', 'models', 'blog.rb'))
      
        it "opens related factory", ->
          atom.commands.dispatch workspaceElement, 'rails-transporter:open-factory'
      
          # Waits until package is activated and active panes count is 2
          waitsFor ->
            activationPromise
            atom.workspace.getActivePane().getItems().length == 2
      
          runs ->
            factoryPath = path.join(atom.project.getPaths()[0], 'spec', 'factories', 'blogs.rb')
            editor = atom.workspace.getActiveTextEditor()
            editor.setCursorBufferPosition new Point(3, 0)
            expect(editor.getPath()).toBe factoryPath
            expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^  factory :blog, :class => 'Blog' do$/
          
      describe "open singular resource filename", ->
        beforeEach ->
          waitsForPromise ->
            atom.workspace.open(path.join(atom.project.getPaths()[0], 'app', 'models', 'entry.rb'))
      
        it "opens related factory", ->
          atom.commands.dispatch workspaceElement, 'rails-transporter:open-factory'
      
          # Waits until package is activated and active panes count is 2
          waitsFor ->
            activationPromise
            atom.workspace.getActivePane().getItems().length == 2
      
          runs ->
            factoryPath = path.join(atom.project.getPaths()[0], 'spec', 'factories', 'entry.rb')
            editor = atom.workspace.getActiveTextEditor()
            editor.setCursorBufferPosition new Point(3, 0)
            expect(editor.getPath()).toBe factoryPath
            expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^  factory :entry, :class => 'Entry' do$/

  
    describe "when active editor opens model-spec", ->
      describe "open plural resource filename", ->
        beforeEach ->
          waitsForPromise ->
            atom.workspace.open(path.join(atom.project.getPaths()[0], 'spec', 'models', 'blog_spec.rb'))
      
        it "opens related factory", ->
          atom.commands.dispatch workspaceElement, 'rails-transporter:open-factory'
      
          # Waits until package is activated and active panes count is 2
          waitsFor ->
            activationPromise
            atom.workspace.getActivePane().getItems().length == 2
      
          runs ->
            factoryPath = path.join(atom.project.getPaths()[0], 'spec', 'factories', 'blogs.rb')
            editor = atom.workspace.getActiveTextEditor()
            editor.setCursorBufferPosition new Point(3, 0)
            expect(editor.getPath()).toBe factoryPath
            expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^  factory :blog, :class => 'Blog' do$/
    
      describe "open singular resource filename", ->
        beforeEach ->
          waitsForPromise ->
            atom.workspace.open(path.join(atom.project.getPaths()[0], 'spec', 'models', 'entry_spec.rb'))
      
        it "opens related factory", ->
          atom.commands.dispatch workspaceElement, 'rails-transporter:open-factory'
      
          # Waits until package is activated and active panes count is 2
          waitsFor ->
            activationPromise
            atom.workspace.getActivePane().getItems().length == 2
      
          runs ->
            factoryPath = path.join(atom.project.getPaths()[0], 'spec', 'factories', 'entry.rb')
            editor = atom.workspace.getActiveTextEditor()
            editor.setCursorBufferPosition new Point(3, 0)
            expect(editor.getPath()).toBe factoryPath
            expect(editor.getLastCursor().getCurrentBufferLine()).toMatch /^  factory :entry, :class => 'Entry' do$/
