# CHANGELOG

## v2.0.4

* Do not raise errors when doing ping() healthchecks - too noisy in error monitoring when remote server disappears

## v2.0.3

* [PXCLAM-6](https://projects.pixl8.london/browse/PXCLAM-6) - FileNotExists error: scary looking errors from vulnerability scanners/hackers

## v2.0.2

* [#4](https://github.com/pixl8/preside-ext-clamav/issues/4) Add configurable remote server call timeout and make the default larger than the java client's default (now 2 seconds)

## v2.0.1

* Fix author attribution in manifest

## v2.0.0

* Add support for ClamAV running as a remote service
* Default scanning to be turned on when settings have not yet been set

## v1.0.9

* Convert to github build system
* Add changelog (from git logs)

## v1.0.8

* Do not read request body just to get a header

## v1.0.6-7

* Build fixes

## v1.0.5

* Add German translations

## v1.0.4

* Skip FileExists check when http / https is found in string

## v1.0.3

* Preparing for public release

## v1.0.2

* Ensures FileExists function is reading simple value only

## v1.0.1

* Adding validation of the scan binary path when saving the config form

## v1.0.0

Initial build
