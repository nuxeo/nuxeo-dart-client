library hop_runner;

import 'dart:async';
import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';
import 'package:hop/src/hop_tasks_experimental.dart' as dartdoc;

import '../test/console_test_harness.dart' as test;

void main() {

  addTask('analyze_libs', createAnalyzerTask(_getLibs));

  addTask('test', createUnitTestTask(test.runTCK));

  addTask('docs', createDartDocTask(
      _getLibs,
      linkApi: true,
      postBuild: dartdoc.createPostBuild(_docsCfg),
      excludeLibs: ['logging']));

  runHop();
}

Future<List<String>> _getLibs() => new Future.value(['lib/automation.dart']);

final _docsCfg = new dartdoc.DocsConfig(
    'Dart Automation Client',
    'https://github.com/nelsonsilva/nuxeo-dart-automation',
    'logo.png', 250, 250,
    (String libName) => libName.startsWith('nuxeo'));