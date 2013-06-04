#!/usr/bin/env dart
// If 'dart' is in your path (and your on a *nix system) the above line makes
// this file directly executable

import 'package:nuxeo/http/standalone.dart' as http;
import '_test_runner.dart';

main() {
  runTests(new http.Client());
}
