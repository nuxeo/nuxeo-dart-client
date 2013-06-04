library automation_tests;

import 'package:unittest/unittest.dart';
import 'package:nuxeo/http.dart' as http;
import 'package:nuxeo/automation.dart' as nuxeo;

const continents = [
                    {"id":"europe","label":"label.directories.continent.europe"},
                    {"id":"africa","label":"label.directories.continent.africa"},
                    {"id":"north-america","label":"label.directories.continent.north-america"},
                    {"id":"south-america","label":"label.directories.continent.south-america"},
                    {"id":"asia","label":"label.directories.continent.asia"},
                    {"id":"oceania","label":"label.directories.continent.oceania"},
                    {"id":"antarctica","label":"label.directories.continent.antarctica"}
                    ];

void runTests(http.Client client) {
  var nx = new nuxeo.Automation(client);
  group('Nuxeo Automation Tests', () {
    test('query a directory', () {
      nx.Directory("continent").then((conts) {
        expect(conts.length, equals(7));
        expect(conts[0]["id"], equals("europe"));
      });

    });
  });
}