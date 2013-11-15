part of nuxeo_client;

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

class Request {

  static final Logger LOG = new Logger("nuxeo.client.request");

  Client nxClient;
  Uri uri;

  String repo;
  Duration execTimeout, uploadTimeout;

  AutomationUploader _batchUploader;

  Request(this.uri, this.nxClient, {
      this.repo, this.execTimeout, this.uploadTimeout}) {
  }

  http.Client get httpClient => nxClient.httpClient;

  setRequestHeaders(http.Request request, {
      String repository,
      String documentSchemas: "dublincore"}) {

    // Set the timeout
    var txTimeout = 5 + ((execTimeout != null) ? execTimeout.inSeconds : 0);
    request.headers.set(HEADER_NX_TX_TIMEOUT, txTimeout.toString());

    // Set the schemas
    if (documentSchemas.isNotEmpty) {
      request.headers.set(HEADER_NX_SCHEMAS, documentSchemas);
    }

    // Set the repository
    if (repository == null) {
      repository = repo;
    }
    if (repository != null) {
      request.headers.set(HEADER_NX_REPOSITORY, repository);
    }
  }

  handleResponse(response) {
    var body = response.body;

    LOG.finest("Response: $body");

    var json = JSON.decode(body);

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
}