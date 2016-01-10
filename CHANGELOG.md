## 1.6.1 Bugfixes
* `open-migration-finder` return files order by name desc
* Fix bug https://github.com/hmatsuda/rails-transporter/issues/84

## 1.6.0 viewFileExtension fallback
* Support viewFileExtensionFallback option

## 1.5.0 Change UI for to open file dialog
* Show modal panel instead of system dialog
* Fix bug https://github.com/hmatsuda/rails-transporter/issues/78

## 1.4.5
* Support `open-model` to open non-namespaced model from view file

## 1.4.4
* Support `open-model` to open non-namespaced model from controller file

## 1.3.1 - Bugfixes
* Fix bug https://github.com/hmatsuda/rails-transporter/issues/80 

## 1.3.0 - Support to open minitest files
* Support `open-test` command to open minitest
* Support `open-spec` command to open request spec from controller 

## 1.2.0 - Support requests spec
* Support `open-controller` command to open controller from requests spec

## 1.1.2 - Fix semver

## 1.1.1 - Remove deprecated selectors

## 1.1.0 - Bugfixes
* Fix bug that couldn't work to open file with new pane from finder

## 1.0.0 - Support Windows and Linux
* Available on Windows and Linux
* Implement `open-factory` command
* `open-controller` and `open-model` support to open concern file

## 0.8.0 - Show dialog to create file when related file is not exist
* Open dialog to create new file for controller,model,helper,spec and partial template.
* Fix clashing bug when active editor opens no file

## 0.7.0 - Change Keymaps and add open-view command
* `open-view` supports to open mailer view
* `open-view` supports to show daialog to create view if no view found

## 0.6.0 - Change Keymaps and add open-view command
* Change keymaps
* `open-view` to open view file where cursor is inside action method on controller

## 0.5.0 - Updates open-view-finder
* Support `open-view-finder` to open mailer view files
* Fix `open-asset` couldn't .erb file

## 0.4.0 - Adds open-layout command
`open-layout` command can open layout file from controllers in following situations:
* When cursor's current buffer row contains layout method, it opens specified layout
* When same base name as the controller exists, it opens layout that same base name as the controller
* When there is no such controller-specific layout, it opens default layout named 'application'

## 0.3.0 - Bugfixes
* Fix `open-partial-template` when render method's arguments are enclosed in parenthesis.

## 0.2.0 - Updates open-helper command
* Implement `open-helper` from view/helper-spec.

## 0.1.0 - First Release
* Initial release, somewhat functional but missing many things.
