#!/usr/bin/env dart

import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';

import 'package:nuxeo_automation/standalone_client.dart' as nuxeo;
import 'tck.dart' as TCK;

main() {
  var nx = new nuxeo.Client(schemas: ["dublincore", "file"]);
  nx.login()
    .then((_) => runTCK(new VMConfiguration(), nx))
    .catchError((e) => fail("Failed to login to Nuxeo"));

}

/// We need a synchronous method to use with Hop
runTCK(Configuration config, [nuxeo.Client nx]) {

  if(nx == null) {
    nx = new nuxeo.Client();
  }

  unittestConfiguration = config;

  TCK.run(nx);

}