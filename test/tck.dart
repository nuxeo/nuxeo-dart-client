library tck;

import 'package:unittest/unittest.dart';
import 'package:nuxeo_automation/http.dart' as http;
import 'package:nuxeo_automation/automation.dart' as nuxeo;
import 'package:logging/logging.dart';
import 'package:logging_handlers/logging_handlers_shared.dart';

import 'dart:async';

part 'tck/crud.dart';
part 'tck/pagination.dart';
part 'tck/blob.dart';

var LOG = new Logger("nuxeo.automation.TCK");

void run(http.Client client) {

  // Setup logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(new PrintHandler());

  groupSep = ' - ';

  try {
    nuxeo.Automation nx = new nuxeo.Automation(client);

    testCRUD(nx);
    testPagination(nx);
    testBlobs(nx);
  } on nuxeo.AutomationException catch(e) {
    LOG.shout(e.message);
  }
}