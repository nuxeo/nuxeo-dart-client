#!/usr/bin/env dart

import 'package:unittest/vm_config.dart';
import 'package:nuxeo/http/standalone.dart' as http;
import 'tck.dart' as TCK;

main() {
  useVMConfiguration();
  TCK.run(new http.Client());
}
