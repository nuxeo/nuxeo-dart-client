part of nuxeo;

class OperationRequest {
  http.Client client;
  Uri uri;
  String opId;
  Uri opUri;
  Duration execTimeout, uploadTimeout;
  String documentSchemas;

  static const ALLOWED_PARAMETERS = const ["operationId", "batchId"];

  OperationRequest(this.opId, this.uri, this.client, {
      this.execTimeout, this.uploadTimeout, this.documentSchemas}) {
    opUri = Uri.parse("$uri/$opId");
  }

  Future<Operation> get op => OperationRegistry.get(uri, client).then((registry) => registry[opId]);

  Future call({
          dynamic input: null,
          Map<String, Object> params: null,
          Map<String, String> context: null,
          String repository,
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
          if (param == null && (!ALLOWED_PARAMETERS.contains(key))) {
            throw new ArgumentError("No such parameter '$key' for operation ${op.id}.");
          }
          if (value != null) {
            data["params"][key] = value;
          }
        });
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

      var request = client.post(opUri, multipart: isMultipart);

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

      // check for multipart request
      if (isMultipart) {
        var params = new http.Blob(content: json, mimetype: CTYPE_REQUEST_NOCHARSET, filename: "request");
        var formData = new http.MultipartFormData();
        formData.append("request", params);
        formData.append(input.filename, input);
        return request.send(formData).then(_handleResponse);
      } else {
        // Set the content type
        request.headers.set(http.HEADER_CONTENT_TYPE, CTYPE_REQUEST_NOCHARSET);
        return request.send(json).then(_handleResponse);
      }

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
            throw new Exception(json("message"));
            break;
        }
      }

}