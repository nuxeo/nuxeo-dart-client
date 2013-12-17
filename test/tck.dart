library tck;

import 'package:unittest/unittest.dart';
import 'package:nuxeo_automation/http.dart' as http;
import 'package:nuxeo_automation/client.dart' as nuxeo;
import 'package:logging/logging.dart';
import 'package:logging_handlers/logging_handlers_shared.dart';

import 'dart:async';
import 'dart:convert' show JSON;

part 'tck/crud.dart';
part 'tck/pagination.dart';
part 'tck/blob.dart';
part 'tck/marshalling.dart';
part 'tck/rest.dart';

var LOG = new Logger("nuxeo.automation.TCK");

void run(nuxeo.Client nx) {
  // Setup logging
  Logger.root.level = Level.WARNING;
  Logger.root.onRecord.listen(new LogPrintHandler());

  groupSep = ' - ';

  testCRUD(nx);
  testPagination(nx);
  testBlobs(nx);
  testMarshalling(nx);
  testREST(nx);
}