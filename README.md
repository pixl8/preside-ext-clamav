# ClamAV AntiVirus for Preside

## Overview

This extension provides anti virus scanning using ClamAV for files uploaded to Preside. See [Wiki](https://github.com/pixl8/preside-ext-clamav/wiki) for complete usage documentation.

## Requirements

The extension required Preside 10.10 and above.

## Installation

Install the extension to your application using [CommandBox](https://docs.preside.org/devguides/config.html#injecting-environment-variables):

```
box install preside-ext-clamav
```

## Remote ClamAV service

As of **2.0.0**, this extension offers support for ClamAV running on a separate machine from your running Preside application. For example, in a Kubernetes cluster, you may run a the `clamav/clamav` docker image as a service that your Preside applications can communicate with.

In order to enable this feature, you must tell Preside the hostname and port of your remote service. This can be acheived either using environment variables, or by setting directly in your Config.cfc:


```cfc
// in Config.cfc
settings.clamav.remoteHostname = "clamav.svc.hostname"
settings.clamav.remotePort     = 3310;
```

```
# environment variables
CLAMAV_REMOTE_HOSTNAME=clamav.svc.hostname
CLAMAV_REMOTE_PORT=3310
```

See [Injecting environment variables](https://docs.preside.org/devguides/config.html#injecting-environment-variables) in the official Preside docs for details on how to do that.

Once these settings are detected, the ClamAV extension will run in "remote server" mode.


