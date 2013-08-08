library hop_runner;

import 'dart:async';
import 'dart:io';
import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';

import '../test/console_test_harness.dart' as test;

void main() {

  addTask('analyze_libs', createAnalyzerTask(_getLibs));

  addTask('test', createUnitTestTask(test.runTCK));

  addTask('docs', createDartDocTask(_getLibs));

  runHop();
}

Future<List<String>> _getLibs() {
  return new Directory('lib').list()
      .where((FileSystemEntity fse) => fse is File)
      .map((File file) => file.path)
      .toList();
}
