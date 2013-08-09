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
 * This class implements the [call] method so it can be invoked as a [Function].
 * Tipically this is called through the [OperationRegistry].
 */
class OperationRequest {

  static final LOG = new Logger("nuxeo.automation.operation");

  http.Client _client;
  Uri _uri;
  String id;
  Uri _opUri;
  Duration execTimeout, uploadTimeout;

  AutomationUploader _batchUploader;

  OperationRequest._(this.id, this._uri, this._client, {
      this.execTimeout, this.uploadTimeout}) {
    _opUri = Uri.parse("$_uri/$id");
  }

  Future<Operation> get op => OperationRegistry.get(_uri, _client).then((registry) => registry[id]);

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
        throw new ArgumentError("No such operation: $id");
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

      var targetUri = _opUri;

      // Check for batch upload
      if (_hasBatchUpload) {
        if (data["params"] == null) {
          data["params"] = {};
        }
        data["params"]["operationId"] = id;
        data["params"]["batchId"] = batchId;

        // Override the target url
        targetUri = Uri.parse("${_uri}/batch/execute");
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

      var request = _client.post(targetUri, multipart: isMultipart);

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
  bool get _hasBatchUpload => _batchUploader != null;

  AutomationUploader get uploader {
    if (_batchUploader == null) {
      _batchUploader = new AutomationUploader(_uri, _client);
    }
    return _batchUploader;
  }
}