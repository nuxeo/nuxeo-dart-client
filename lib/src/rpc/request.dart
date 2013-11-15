part of nuxeo_automation_client;

/**
 * [OperationRequest] wraps an [Operation] call.
 * This class implements the [call] method so it can be invoked as a [Function].
 * Tipically this is called through the [OperationRegistry].
 */
class OperationRequest extends nx.Request {

  static final Logger LOG = new Logger("nuxeo.client.request");

  String id;
  Uri _opUri;
  Duration execTimeout, uploadTimeout;

  nx.AutomationUploader _batchUploader;

  OperationRequest(this.id, Uri uri, nx.Client client, {
      this.execTimeout, this.uploadTimeout}) : super(uri, client) {
    _opUri = Uri.parse("$uri/$id");
  }

  Future<nx.Operation> get op => nx.OperationRegistry.get(uri, httpClient).then((registry) => registry[id]);

  /// Call the operation.
  /// Returns a [Future]
  /// Throws [ClientException]
  Future call({
          dynamic input: null,
          Map<String, Object> params: null,
          Map<String, String> context: null,
          String repository,
          String documentSchemas: "dublincore",
          bool voidOp: false}) => op.then((nx.Operation op) {

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

      var request = httpClient.post(targetUri, multipart: isMultipart);

      // Setup the headers
      setRequestHeaders(request, repository: repository, documentSchemas: documentSchemas);

      request.headers.set(nx.HEADER_NX_VOIDOP, voidOp.toString());

      var json = JSON.encode(data);
      LOG.finest("Request: $json");

      // The data to send
      var requestData;

      // check for multipart request
      if (isMultipart) {
        var params = new http.Blob(content: json, mimetype: nx.CTYPE_REQUEST_NOCHARSET, filename: "request");
        var formData = new http.MultipartFormData();
        formData.append("request", params);
        formData.append(input.filename, input);
        requestData = formData;
      } else {
        // Set the content type
        request.headers.set(http.HEADER_CONTENT_TYPE, nx.CTYPE_REQUEST_NOCHARSET);
        requestData = json;
      }

      return request
          .send(requestData)
          .catchError((e) {
            throw new nx.ClientException(e.message);
          })
          .then(handleResponse);


  });

  String get batchId => _batchUploader.batchId;
  bool get _hasBatchUpload => _batchUploader != null;

  nx.AutomationUploader get uploader {
    if (_batchUploader == null) {
      _batchUploader = new nx.AutomationUploader(uri, httpClient);
    }
    return _batchUploader;
  }
}