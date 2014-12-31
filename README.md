# Rails Transporter [![Build Status](https://travis-ci.org/hmatsuda/rails-transporter.svg?branch=master)](https://travis-ci.org/hmatsuda/rails-transporter) [![Build status](https://ci.appveyor.com/api/projects/status/jnr0p97ero2wh1j2/branch/master?svg=true)](https://ci.appveyor.com/project/hmatsuda/rails-transporter/branch/master)

This package provides commands to open file depending on file which is being opened by active editor.

![screenshot](http://cl.ly/image/43053A1J2b17/rails-transporter.gif)

## Commands

### open-controller (`ctrl-r c`)
This command provides 2 features.

#### Open related controller
It opens controller file from `model`, `view` or `ontroller-spec`.

e.g. When active editor is opening: 
`app/models/user.rb`, `app/views/users/*.html.erb` or `spec/controllers/users_controller_spec.rb`,
`open-controller` opens `app/controllers/users_controller.rb`.

#### Open controller concern
It opens concern file from controller.

e.g. If active editor opens below file and cursor is on the `include` method,
```ruby
class BlogsController < ApplicationController
  include Blog::Taggable
end
```
`open-controller` opens `app/controllers/concerns/blog/taggable.rb`.

If no controller or concern found, show dialog to create new file.

### open-model (`ctrl-r m`)
This command provides 2 features.

#### Open related model
It opens related model file from `controller`, `view`, `model-spec` or `factory`.

e.g. When active editor is opening: 
`app/controllers/users_controller.rb`, `app/views/users/*.html.erb`, `spec/models/user_spec.rb` or `spec/factories/users.rb`,

`open-model` opens `app/models/user.rb`.

#### Open model concern
It opens concern file from model.

e.g. If active editor opens below file and cursor is on the `include` method,
```ruby
class Item < ActiveRecord::Base
  include Searchable
end
```
`open-model` opens `app/models/concerns/searchable.rb`.

If no model or concern found, show dialog to create new file.

### open-view (`ctrl-r v`)
It opens related view for action method of controller.

When active editor is opening controller and cursor is inside action method, `open-view` opens the related view file.

e.g. When you open a below controller,
```ruby
class UsersController < ApplicationController
  def index
    @users = User.all
  end
  
  def show
    @user = User.find(params[:id])
  end
end
```

if cursor is inside `index` method, `open-view` opens `app/views/users/index.html.erb`
else if cursor is inside `show` method, `open-view` opens `app/views/users/show.html.erb` else, do nothing.

If no related view found, show dialog to create new file.

If you want to change template engine like haml, override default setting in setting view.
![View File Extension](http://cl.ly/image/2m31390Z0Z34/Settings_-__Users_hakutoitoi__ghq_github_com_hmatsuda_rails-transporter_-_Atom.png)

### open-view-finder (`ctrl-r v`)
It opens related view files of controller.

e.g. When active editor is opening `app/controllers/blogs_controller.rb`, `open-view-finder` opens related view list.
![](http://cl.ly/image/1t0A0D220S3C/blogs_controller_rb_-__Users_hakutoitoi__ghq_github_com_hmatsuda_rails-transporter_spec_fixtures_-_Atom.png)

### open-layout (`ctrl-r l`)
It opens related layout from `layout` method in controller.

e.g. When active editor is opening controller, `open-layout` opens the related view layout file.
This command provides 2 behavior to open layout file. When active editor is opening a below controller,
```ruby
class UsersController < ApplicationController
  
  layout 'user_dashboard'
  
end
```
First, cursor is on the `layout` method, `open-layout` opens `app/views/layouts/user_dashboard.html.erb` if it exists.

Second, when cursor isn't on the `layout` method, it opens `app/views/layouts/users.html.erb` if it doesn't exist, opens `app/views/layouts/application.html.erb`.

The first behavior has a priority to apply.

### open-helper (`ctrl-r h`)
It opens related helper from `controller`, `model`, `view` or `helper-spec`.

e.g. When active editor is opening: 

`app/controllers/users_controller.rb`, `app/models/user.rb`, `app/views/users/*.html.erb` or `spec/helpers/users_helper_spec.rb`,

`open-helper` opens `app/helpers/users_helper.rb`.

If no helper found, show dialog to create new file.


### open-spec (`ctrl-r s`)
It opens related spec from `controller`, `model`, `helper` or `factory`.

e.g. When active editor is opening: 

`app/controllers/users_controller.rb`, it opens `spec/controllers/users_controller_spec.rb`.

`app/models/user.rb` or `spec/factories/users.rb`, it opens `spec/models/user_spec.rb`.

`app/helpers/users_helper.rb`, it opens `spec/helpers/users_helper_spec.rb`.



If no spec found, show dialog to create new file.

### open-partial-template (`ctrl-r p`)
It opens partial template from `render` method.

e.g. When active editor is opening a below view file and cursor is on the `render` method,
```ruby
<section id="contents">

<%= render 'sidebar' %>

</section>
```
`open-partial-template` opens `app/views/users/_sidebar.html.erb`.

If no related view found, show dialog to create new file.

### open-asset (`ctrl-r a`)
It opens related asset file from view or asset file.

e.g. 
* When active editor is opening a below view,
```html
<html>
<html>
<head>
<%= stylesheet_link_tag "user" %>
<%= javascript_include_tag "user" %>
<%= csrf_meta_tags %>
</head>
<body>
<%= yield %>
</body>
</html>
```
when cursor is on `javascript_include_tag` method, it opens `app/assets/javascripts/user.js`,
when cursor is on `stylesheet_link_tag` method, it opens `app/assets/stylesheets/user.css`.

* When it is opening a asset file as following and cursor is on the `require` method,
```coffee
//= require my_library
```
it opens javascript file if it exists.

* When it is opening a asset file as following and cursor is on the `require_tree` or `require_directory` method,
```coffee
//= require_tree shared
//= require_directory shared
```
it opens related asset file list
![](http://cl.ly/image/1G2D240f1A0i/application01_js_-__Users_hakutoitoi__ghq_github_com_hmatsuda_rails-transporter_spec_fixtures_-_Atom.png)

### open-mingration-finder (`ctrl-r d m`)
It opens all of migration list.
![](http://cl.ly/image/3y0F2D1H1w2F/application01_js_-__Users_hakutoitoi__ghq_github_com_hmatsuda_rails-transporter_spec_fixtures_-_Atom.png)

### open-factory (`ctrl-r f`)
It opens related factory file from `model` or `model-spec`.

e.g. When active editor is opening: 

`app/models/user.rb`, or `spec/models/user_spec.rb`,

`open-spec` opens `spec/factories/blogs.rb`.

If no factory found, show dialog to create new file.


## Requirement
* Ruby 1.9.3+
* Rails 2.0.0+

## Contributors
* joseramonc

## Contributing
1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request
