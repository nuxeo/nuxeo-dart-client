library nuxeo;

import 'dart:uri';
import 'dart:async';
import 'dart:json' as JSON;
import 'package:nuxeo/http.dart' as http;

part 'src/request.dart';
part 'src/operation.dart';
part 'src/registry.dart';

const CTYPE_AUTOMATION = "application/json+nxautomation";
const CTYPE_ENTITY = "application/json+nxentity";
const CTYPE_REQUEST_NOCHARSET = "application/json+nxrequest";

class Automation {

  http.Client client;

  Automation(this.client);

  op(String id) => new OperationRequest(id, client);

  Directory(String name) => op("Directory.Entries")({"directoryName": name});
}
