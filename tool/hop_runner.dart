library hop_runner;

import 'dart:async';
import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';
import 'package:hop_docgen/hop_docgen.dart';
import 'package:logging/logging.dart';

import '../test/console_test_harness.dart' as test;

void main(List<String> args) {

  addTask('analyze_libs', createAnalyzerTask(_getLibs));

  addTask('test', createUnitTestTask(test.runTCK));

  addTask('docs', createDocGenTask('../compiled_dartdoc_viewer'));

  runHop(args, printAtLogLevel: Level.ALL);
}

Future<List<String>> _getLibs() => new Future.value(['lib/client.dart']);

final _docsCfg = new dartdoc.DocsConfig(
    'Dart Automation Client',
    'https://github.com/nelsonsilva/nuxeo-dart-automation',
    'logo.png', 250, 250,
    (String libName) => libName.startsWith('nuxeo'));