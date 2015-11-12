![Nuxeo Dart](https://raw.github.com/nuxeo/nuxeo-dart-client/master/resource/nuxeo_dart.png)

## Dart Client Library for Nuxeo API

[![Build Status](https://qa.nuxeo.org/jenkins/buildStatus/icon?job=nuxeo-dart-client-master)](https://qa.nuxeo.org/jenkins/job/nuxeo-dart-client-master/)

Dart client library for the Nuxeo Automation and REST API.

The library can work in a browser, or in the console using the same API.

## Getting started

* Get the latest [Nuxeo Fast Track Release](http://www.nuxeo.com/en/downloads).
* Get the latest [Tools for Dart](http://www.dartlang.org/tools/).

## Try It

* Start the Dart Editor
* Create a new Dart project
* Add the nuxeo_client dependency to your `pubspec.yaml` file.
```yaml
dependencies:
  nuxeo_client: any
```
* Import the nuxeo_client library:
    - For browser applications use:
```
import 'package:nuxeo_client/browser_client.dart' as nuxeo;
```
    - For standalone/console applications use:
```
import 'package:nuxeo_client/standalone_client.dart' as nuxeo;
```

* Create your client:
```
var nx = new nuxeo.Client()
```

* Call some operations, for instance:
```
nx.op("Document.GetChildren")(input:"doc:/")
  .then((docs) {
    ...
  });
```

* Checkout the docs for more.

## Documentation

[API Reference](http://nuxeo.github.io/nuxeo-dart-client/)

## Running the TCK

Nuxeo provides a [TCK](http://doc.nuxeo.com/display/NXDOC/Automation+API+and+client+library) (Test Compatibility Kit) that can be used to test the implementation of an automation client library.

You can run the Dart Automation Client TCK with your own Nuxeo server (version >= 5.8).

#### Prerequisites

* Download [nuxeo-automation-test](https://maven-us.nuxeo.org/nexus/content/groups/public/org/nuxeo/ecm/automation/nuxeo-automation-test/5.8/nuxeo-automation-test-5.8.jar) to nxserver/bundles
* Install nuxeo-rest-api
```
nuxeoctl mp-install nuxeo-rest-api --accept true
```

### Standalone Nuxeo Client

* Start Nuxeo server
* Run the console tests harness at test/console_test_harness.dart
* Check the console output for the test results

### Browser Nuxeo Client

#### Setup CORS

* Add a CORS config contribution to allow Dartium to do cross-domain requests to your Nuxeo server:

```xml
<?xml version="1.0"?>
<component name="org.nuxeo.ecm.platform.web.dart.tck">
 <extension target="org.nuxeo.ecm.platform.web.common.requestcontroller.service.RequestControllerService" point="corsConfig">
    <corsConfig name="dartTCK" allowOrigin="http://127.0.0.1:3030" supportedMethods="GET,POST,HEAD,OPTIONS,PUT,DELETE">
      <pattern>/nuxeo/site/automation.*</pattern>
    </corsConfig>
    <corsConfig name="dartTCKApi" allowOrigin="http://127.0.0.1:3030" supportedMethods="GET,POST,HEAD,OPTIONS,PUT,DELETE">
      <pattern>/nuxeo/api.*</pattern>
    </corsConfig>
  </extension>
</component>
```

You can just put it in a *-config.xml file in nxserver/config or create a custom template (don't forget to update nuxeo.conf).

You can check if CORS is working properly with curl:
```
curl --verbose -u Administrator:Administrator -H "Origin: http://127.0.0.1:3030" -H "Access-Control-Request-Method: POST" -H "Access-Control-Request-Headers: X-Requested-With" -X OPTIONS http://localhost:8080/nuxeo/site/automation
```

#### Run the TCK

* Start Nuxeo server
* Run the console based tests

     dart test/console_test_harness.dart    

* Run the browser tests harness at test/browser_test_harness.dart

     use 'Run in Dartium' from Dart Editor

* Check the browser for the test results

## Authors
 * [Nelson Silva](https://github.com/nelsonsilva) ([+Nelson Silva](https://plus.google.com/114313790760784276282/))

## About Nuxeo

Nuxeo provides a modular, extensible Java-based [open source software platform for enterprise content management] [1] and packaged applications for [document management] [2], [digital asset management] [3] and [case management] [4]. Designed by developers for developers, the Nuxeo platform offers a modern architecture, a powerful plug-in model and extensive packaging capabilities for building content applications.

[1]: http://www.nuxeo.com/en/products/ep
[2]: http://www.nuxeo.com/en/products/document-management
[3]: http://www.nuxeo.com/en/products/dam
[4]: http://www.nuxeo.com/en/products/case-management

More information on: <http://www.nuxeo.com/>
