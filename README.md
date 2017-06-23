# ClamAV AntiVirus for Preside

## Overview

This extension provides anti virus scanning using ClamAV (unix servers only) for files uploaded to Preside. See [Wiki](https://github.com/pixl8/preside-ext-clamav/wiki) for complete usage documentation.

## Installation

Install the extension to your application via either of the methods detailed below (Git submodule / CommandBox) and then enable the extension by opening up the Preside developer console and entering:

```
extension enable preside-ext-clamav
reload all
```

### CommandBox (box.json) method

From the root of your application, type the following command:

```
box install preside-ext-clamav
```

### Git Submodule method

From the root of your application, type the following command:

```
git submodule add https://github.com/pixl8/preside-ext-sentry.git application/extensions/preside-ext-clamav
```


