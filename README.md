![Nuxeo Dart](https://raw.github.com/nelsonsilva/nuxeo-dart-automation/master/resource/nuxeo_dart.png)

## A Nuxeo Automation client in Dart

[![Build Status](https://drone.io/github.com/nelsonsilva/nuxeo-dart-automation/status.png)](https://drone.io/github.com/nelsonsilva/nuxeo-dart-automation/latest)

## Getting started

* Get the latest [Nuxeo Fast Track Release](http://www.nuxeo.com/en/downloads).
* Get the latest [Tools for Dart](http://www.dartlang.org/tools/).

## Try It

* Start the Dart Editor
* Create a new Dart project
* Add the nuxeo_automation dependency to your `pubspec.yaml` file.
```yaml
dependencies:
  nuxeo_automation: any
```
* Import the nuxeo_automation library:
    - For browser applications use:
```
import 'package:nuxeo_automation/browser_client.dart' as nuxeo_automation;
```
    - For standalone/console applications use:
```
import 'package:nuxeo_automation/standalone_client.dart' as nuxeo_automation;
```

* Create your client:
```
var nx = new nuxeo_automation.Client()
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

[API Reference](http://nelsonsilva.github.io/nuxeo-dart-automation/nuxeo_client.html)

## Running the TCK

Nuxeo provides a [TCK](http://doc.nuxeo.com/display/NXDOC/Automation+API+and+client+library) (Test Compatibility Kit) that can be used to test the implementation of an automation client library.

You can run the Dart Automation Client TCK with your own Nuxeo server (version >= 5.8).

#### Prerequisites

* Download [nuxeo-automation-test](https://maven-us.nuxeo.org/nexus/content/groups/public/org/nuxeo/ecm/automation/nuxeo-automation-test/5.8/nuxeo-automation-test-5.8.jar) to nxserver/bundles
* Install nuxeo-rest-api
```
nuxeoctl mp-install nuxeo-rest-api --accept true
```

### Standalone Automation Client

* Start Nuxeo server
* Run the console tests harness at test/console_test_harness.dart
* Check the console output for the test results

### Browser Automation Client

#### Setup CORS

* Add a CORS config contribution to allow Dartium to do cross-domain requests to your Nuxeo server:

```xml
<?xml version="1.0"?>
<component name="org.nuxeo.ecm.platform.web.dart.tck">
  <extension target="org.nuxeo.ecm.platform.web.common.requestcontroller.service.RequestControllerService" point="corsConfig">
    <corsConfig name="dartTCK" allowOrigin="http://127.0.0.1:3030">
      <pattern>/nuxeo/api/.*</pattern>
      <pattern>/nuxeo/site/automation/.*</pattern>
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
* Run the browser tests harness at test/browser_test_harness.dart
* Check the browser for the test results

## Authors
 * [Nelson Silva](https://github.com/nelsonsilva) ([+Nelson Silva](https://plus.google.com/114313790760784276282/))
