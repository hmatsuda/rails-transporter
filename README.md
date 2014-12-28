# Rails Transporter [![Build Status](https://travis-ci.org/hmatsuda/rails-transporter.svg?branch=master)](https://travis-ci.org/hmatsuda/rails-transporter) [![Build status](https://ci.appveyor.com/api/projects/status/jnr0p97ero2wh1j2/branch/master?svg=true)](https://ci.appveyor.com/project/hmatsuda/rails-transporter/branch/master)

This package provides commands to open file depending on file which is being opened by active editor.

![](http://cl.ly/image/3C0X3H0S2r29/rails-transporter.gif)

## Commands

### open-controller (`ctrl-r c`)
When active editor is opening: 

`app/models/user.rb`, `app/views/users/*.html.erb` or `spec/controllers/users_controller_spec.rb`,

`open-controller` opens `app/controllers/users_controller.rb`.

If no controller found, show dialog to create new file.

### open-model (`ctrl-r m`)
When active editor is opening: 

`app/controllers/users_controller.rb`, `app/views/users/*.html.erb` or `spec/models/user_spec.rb`,

`open-model` opens `app/models/user.rb`.

If no model found, show dialog to create new file.

### open-view (`ctrl-r v`)
When active editor is opening `app/controllers/users_controller.rb` and cursor is inside action method, `open-view` opens the related view file.

e.g.

When you open a below controller,
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

### open-view-finder (`ctrl-r v`)
It opens related view files of controller.

When active editor is opening `app/controllers/blogs_controller.rb`, it opens related view finder.
![](http://cl.ly/image/1t0A0D220S3C/blogs_controller_rb_-__Users_hakutoitoi__ghq_github_com_hmatsuda_rails-transporter_spec_fixtures_-_Atom.png)

### open-layout (`ctrl-r l`)
When active editor is opening controller, `open-layout` opens the related view layout file.

This command provides 2 behavior to open file. When active editor is opening a below controller,
```ruby
class UsersController < ApplicationController
  
  layout 'user_dashboard'
  
end
```
First, cursor is on the `layout` method, `open-layout` opens `app/views/layouts/user_dashboard.html.erb` if it exists.

Second, when cursor isn't on the `layout` method, it opens `app/views/layouts/users.html.erb` if it doesn't exist, opens `app/views/layouts/application.html.erb`.

The first behavior has a priority to apply.

### open-helper (`ctrl-r h`)
It opens related helper.

When active editor is opening: 

`app/helpers/users_helper.rb`, `app/controllers/users_controller.rb`, `app/views/users/*.html.erb` or `spec/helpers/users_helper_spec.rb`,

`open-helper` opens `app/helpers/users_helper.rb`.

If no helper found, show dialog to create new file.


### open-spec (`ctrl-r s`)
It opens related spec.

When active editor is opening: 

`app/controllers/users_controller.rb`, it opens `spec/controllers/users_controller_spec.rb`.

`app/models/user.rb`, it opens `spec/models/user_spec.rb`.

`app/helpers/users_helper.rb`, it opens `spec/helpers/users_helper_spec.rb`.

If no spec found, show dialog to create new file.

### open-partial-template (`ctrl-r p`)
It opens partial template.

When active editor is opening a below view file and cursor is on the `render` method,
```ruby
<section id="contents">

<%= render 'sidebar' %>

</section>
```
`open-partial-template` opens `app/views/users/_sidebar.html.erb`.

If no related view found, show dialog to create new file.

### open-asset (`ctrl-r a`)
It opens related asset file from view or asset file.

1. When active editor is opening a below view,
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

2. When it is opening a asset file as following and cursor is on the `require` method,
```coffee
//= require my_library
```
it opens javascript file if it exists.

3. When it is opening a asset file as following and cursor is on the `require_tree` or `require_directory` method,
```coffee
//= require_tree shared
//= require_directory shared
```
it opens related asset finder
![](http://cl.ly/image/1G2D240f1A0i/application01_js_-__Users_hakutoitoi__ghq_github_com_hmatsuda_rails-transporter_spec_fixtures_-_Atom.png)

### open-mingration-finder (`ctrl-d-m`)
It opens all of migration files.
![](http://cl.ly/image/3y0F2D1H1w2F/application01_js_-__Users_hakutoitoi__ghq_github_com_hmatsuda_rails-transporter_spec_fixtures_-_Atom.png)


## Requirement
* Ruby 1.9.3+
* Rails 2.0.0+
