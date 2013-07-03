library tck;

import 'package:unittest/unittest.dart';
import 'package:nuxeo/http.dart' as http;
import 'package:nuxeo/automation.dart' as nuxeo;
import 'package:logging/logging.dart';
import 'package:logging_handlers/logging_handlers_shared.dart';

import 'dart:async';

part 'tck/crud.dart';
part 'tck/pagination.dart';
part 'tck/blob.dart';

void run(http.Client client) {

  // Setup logging
  hierarchicalLoggingEnabled = true;
  Logger.root.onRecord.listen(new PrintHandler());

  groupSep = ' - ';

  nuxeo.Automation nx = new nuxeo.Automation(client);

  testCRUD(nx);
  testPagination(nx);
  testBlobs(nx);
}