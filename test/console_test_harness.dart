#!/usr/bin/env dart

import 'dart:io';
import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';

import 'package:nuxeo_automation/standalone_client.dart' as nuxeo;
import 'tck.dart' as TCK;

main() {
  var nx = new nuxeo.Client();

  nx.login
    .catchError((e) =>
        throw new nuxeo.ClientException("Failed to login to Nuxeo: ${e.message}"))
     .then((_) =>  runTCK(new VMConfiguration(), nx));
 ;
}

/// We need a synchronous method to use with Hop
runTCK(Configuration config, [nuxeo.Client nx]) {

  if(nx == null) {
    nx = new nuxeo.Client();
  }

  unittestConfiguration = config;

  TCK.getResource = (String filename) => new File(filename).readAsString();

  TCK.run(nx);

}