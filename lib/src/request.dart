part of nuxeo_automation;

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

/**
 * [OperationRequest] wraps an [Operation] call.
 * This class implements the [call] method this it can be invoked as a [Function].
 * Tipically this is called throught the [OperationRegistry].
 */
class OperationRequest {

  static final LOG = new Logger("nuxeo.automation.operation");

  http.Client client;
  Uri uri;
  String opId;
  Uri opUri;
  Duration execTimeout, uploadTimeout;

  AutomationUploader _batchUploader;

  OperationRequest(this.opId, this.uri, this.client, {
      this.execTimeout, this.uploadTimeout}) {
    opUri = Uri.parse("$uri/$opId");
  }

  Future<Operation> get op => OperationRegistry.get(uri, client).then((registry) => registry[opId]);

  /// Call the operation.
  /// Returns a [Future]
  /// Throws [AutomationException]
  Future call({
          dynamic input: null,
          Map<String, Object> params: null,
          Map<String, String> context: null,
          String repository,
          String documentSchemas: "dublincore",
          bool voidOp: false}) => op.then((Operation op) {

      if (op == null) {
        throw new ArgumentError("No such operation: $opId");
      }

      var data = {};

      // Setup the parameters
      if (params != null) {
        data["params"] = {};
        params.forEach((key, value) {
          var param = op[key];
          if (param == null) {
            throw new ArgumentError("No such parameter '$key' for operation ${op.id}.");
          }
          if (value != null) {
            data["params"][key] = value;
          }
        });
      }

      var targetUri = opUri;

      // Check for batch upload
      if (hasBatchUpload) {
        if (data["params"] == null) {
          data["params"] = {};
        }
        data["params"]["operationId"] = opId;
        data["params"]["batchId"] = batchId;

        // Override the target url
        targetUri = Uri.parse("${uri}/batch/execute");
      }

      var isMultipart = (input is http.Blob);

      // Setup the input
      if (input != null && !isMultipart) {
        data["input"] = input;
      }

      // Setup the context
      if (context != null) {
        data["context"] = context;
      }

      var request = client.post(targetUri, multipart: isMultipart);

      // Setup the headers
      var txTimeout = 5 + ((execTimeout != null) ? execTimeout.inSeconds : 0);

      request.headers.set(HEADER_NX_VOIDOP, voidOp.toString());
      request.headers.set(HEADER_NX_TX_TIMEOUT, txTimeout.toString());
      if (documentSchemas.isNotEmpty) {
        request.headers.set(HEADER_NX_SCHEMAS, documentSchemas);
      }
      if (repository != null) {
        request.headers.set(HEADER_NX_REPOSITORY, repository);
      }

      var json = JSON.stringify(data);

      // The data to send
      var requestData;

      // check for multipart request
      if (isMultipart) {
        var params = new http.Blob(content: json, mimetype: CTYPE_REQUEST_NOCHARSET, filename: "request");
        var formData = new http.MultipartFormData();
        formData.append("request", params);
        formData.append(input.filename, input);
        requestData = formData;
      } else {
        // Set the content type
        request.headers.set(http.HEADER_CONTENT_TYPE, CTYPE_REQUEST_NOCHARSET);
        requestData = json;
      }

      return request
          .send(requestData)
          .catchError((e) {
            throw new AutomationException(e.message);
          })
          .then(_handleResponse);


  });

  _handleResponse(response) {
    var body = response.body,
        json = JSON.parse(body);

    switch (json["entity-type"]) {
      case "document":
        return new Document.fromJSON(json);
        break;
      case "documents":
        var docs = json["entries"].map((doc) => new Document.fromJSON(doc));

        if (!json.containsKey("isPaginable") || !json["isPaginable"]) {
          return docs;
        }

        return new PaginableDocuments(docs)
            ..totalSize = json["totalSize"]
            ..pageIndex = json["pageIndex"]
            ..pageSize = json["pageSize"]
            ..pageCount = json["pageCount"];

        break;
      case "exception":
        throw new Exception(json["message"]);
        break;
    }
  }

  String get batchId => _batchUploader.batchId;
  bool get hasBatchUpload => _batchUploader != null;

  AutomationUploader get uploader {
    if (_batchUploader == null) {
      _batchUploader = new AutomationUploader(uri, client);
    }
    return _batchUploader;
  }
}