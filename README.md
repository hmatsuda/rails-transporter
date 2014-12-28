# Rails Transporter package [![Build Status](https://travis-ci.org/hmatsuda/rails-transporter.svg?branch=master)](https://travis-ci.org/hmatsuda/rails-transporter) [![Build status](https://ci.appveyor.com/api/projects/status/jnr0p97ero2wh1j2)](https://ci.appveyor.com/api/projects/status/jnr0p97ero2wh1j2/branch/master?svg=true)

This package provides commands to open controller, view, model, helper template, asset and migration on Ruby on Rails on Atom editor.

Quickly open files or finder using following keymaps.

* `ctrl-r c` - Open controller from model, view or controller-spec. If no controller found, show dialog to create new file
* `ctrl-r v f` - Open view finder from controller, model or mailer
* `ctrl-r v` - Open view where the cursor is inside action method on controller. If no view found, show dialog to create new file
* `ctrl-r l` - Open layout from view
* `ctrl-r m` - Open model from controller, view or model-spec. If no model found, show dialog to create new file
* `ctrl-r h` - Open helper from controller, view or helper-spec. If no helper found, show dialog to create new file
* `ctrl-r s` - Open spec from controller, helper or model. If no spec found, show dialog to create new file
* `ctrl-r p` - Open partial template from render method in view. If no partial template found, show dialog to create new file
* `ctrl-r a` - Open asset from javascript_include_tag or stylesheet_link_tag method in view
* `ctrl-r d m` - Open migration finder

![](http://cl.ly/image/0q2B370v3S3Y/out.gif)

## Requirement
* OSX
* Ruby 1.9.3+
* Rails 2.0.0+
