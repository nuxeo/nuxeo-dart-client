library nuxeo;

import 'dart:async';
import 'dart:collection';
import 'dart:math' as Math;
import 'dart:json' as JSON;
import 'package:nuxeo/http.dart' as http;
import 'package:logging/logging.dart';

part 'src/request.dart';
part 'src/operation.dart';
part 'src/uploader.dart';
part 'src/registry.dart';
part 'src/document.dart';

const CTYPE_AUTOMATION = "application/json+nxautomation";
const CTYPE_ENTITY = "application/json+nxentity";
const CTYPE_REQUEST_NOCHARSET = "application/json+nxrequest";
const CTYPE_MULTIPART_RELATED = "multipart/related";
const CTYPE_MULTIPART_MIXED = "multipart/mixed";
const CTYPE_REQUEST = "application/json+nxrequest; charset=UTF-8";
const KEY_ENTITY_TYPE = "entity-type";
const HEADER_NX_SCHEMAS = "X-NXDocumentProperties";
const HEADER_NX_VOIDOP = "X-NXVoidOperation";
const HEADER_NX_TX_TIMEOUT = "Nuxeo-Transaction-Timeout";
const HEADER_NX_REPOSITORY = "X-NXRepository";


class Automation {

  static final LOG = new Logger("nuxeo.automation");

  http.Client client;
  Uri uri;
  AutomationUploader _batchUploader;

  Automation(this.client, [String url = "http://localhost:8080/nuxeo/site/automation"]) {
    uri = Uri.parse(url);
  }

  OperationRequest op(String id, {
    execTimeout: const Duration(seconds: 30),
    uploadTimeout: const Duration(minutes: 20),
    documentSchemas: "dublincore"
  }) => new OperationRequest(id, uri, client,
      execTimeout: execTimeout,
      uploadTimeout: uploadTimeout,
      documentSchemas: documentSchemas);


  AutomationUploader get uploader {
    if (_batchUploader == null) {
      _batchUploader = new AutomationUploader(this);
    }
    return _batchUploader;
  }

  Future<OperationRegistry> get registry => OperationRegistry.get(uri, client);

}
