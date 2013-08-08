#!/usr/bin/env dart

import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';

import 'package:nuxeo_automation/standalone_client.dart' as nuxeo;
import 'tck.dart' as TCK;

main() {
  runTCK(new VMConfiguration());
}

runTCK(Configuration config) {
  unittestConfiguration = config;
  TCK.run(new nuxeo.Client());
}