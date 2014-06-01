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
