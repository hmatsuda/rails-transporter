# Rails Transporter package [![Build Status](https://travis-ci.org/hmatsuda/rails-transporter.svg)](https://travis-ci.org/hmatsuda/rails-transporter)

This package provides commands to open controller, view, model, helper template, asset and migration on Ruby on Rails on Atom editor.

Quickly open files or finder using following keymaps.

* `ctrl-r c` - Open controller from model, view or controller-spec
* `ctrl-r v f` - Open view finder from controller, model or mailer
* `ctrl-r v` - Open view where the cursor is inside action method on controller. If no view found, show dialog to create new file
* `ctrl-r l` - Open layout from view
* `ctrl-r m` - Open model from controller, view or model-spec
* `ctrl-r h` - Open helper from controller, view or helper-spec
* `ctrl-r s` - Open spec from controller, helper or model
* `ctrl-r p` - Open partial template from render method in view
* `ctrl-r a` - Open asset from javascript_include_tag or stylesheet_link_tag method in view
* `ctrl-r d m` - Open migration finder

![](http://cl.ly/image/0q2B370v3S3Y/out.gif)

## Requirement
* OSX
* Ruby 1.9.3+
* Rails 2.0.0+
