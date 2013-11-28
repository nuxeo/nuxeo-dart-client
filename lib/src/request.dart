part of nuxeo_client;

const CTYPE_AUTOMATION = "application/json+nxautomation";
const CTYPE_ENTITY = "application/json+nxentity";
const CTYPE_JSON = "application/json";
const CTYPE_REQUEST_NOCHARSET = "application/json+nxrequest";
const CTYPE_MULTIPART_RELATED = "multipart/related";
const CTYPE_MULTIPART_MIXED = "multipart/mixed";
const CTYPE_REQUEST = "application/json+nxrequest; charset=UTF-8";
const KEY_ENTITY_TYPE = "entity-type";
const HEADER_NX_SCHEMAS = "X-NXDocumentProperties";
const HEADER_NX_VOIDOP = "X-NXVoidOperation";
const HEADER_NX_TX_TIMEOUT = "Nuxeo-Transaction-Timeout";
const HEADER_NX_REPOSITORY = "X-NXRepository";

abstract class BaseRequest {

  static final Logger LOG = new Logger("nuxeo.client.request");

  Client nxClient;
  Uri uri;

  String repo;
  Duration execTimeout, uploadTimeout;

  AutomationUploader _batchUploader;

  BaseRequest(this.uri, this.nxClient, {
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

  _createEntity(json) {
    switch (json["entity-type"]) {
      case "document":
        return new Document.fromJSON(json);
      default:
        return BusinessAdapter.fromJSON(json);
    }
  }

  handleResponse(response) {
    var body = response.body;

    if (response.headers["content-type"] == CTYPE_ENTITY ||
        response.headers["content-type"] == CTYPE_JSON) {
      LOG.finest("Response: $body");

      var json = JSON.decode(body);

      switch (json["entity-type"]) {
        case "document":
        case "adapter":
          return _createEntity(json);

        case "documents":
        case "adapters":

          var entries = [];
          json["entries"].forEach((entry) {
            var entity = _createEntity(entry);
            if (entity != null) {
              entries.add(entity);
            }
          });

          if (!json.containsKey("isPaginable") || !json["isPaginable"]) {
            return entries;
          }

          // Find out the type of an entry
          Type T = Object;
          if (entries.isNotEmpty) {
            T = entries.first.runtimeType;
          } else {

            if (json["entity-type"] == "documents") {
              T = Document;
            }
            // We have no way to know the type for empty adapters list
          }

          return new Pageable(entries)
            ..totalSize = json["totalSize"]
            ..currentPageIndex = json["currentPageIndex"]
            ..currentPageSize = json["currentPageSize"]
            ..isLastPageAvailable = json["isLasPageAvailable"]
            ..isNextPageAvailable = json["isNextPageAvailable"]
            ..isPreviousPageAvailable = json["isPreviousPageAvailable"]
            ..isSortable = json["isSortable"]
            ..maxPageSize = json["maxPageSize"]
            ..numberOfPages = json["numberOfPages"]
            ..pageSize = json["pageSize"];

          break;
        case "exception":
          throw new Exception(json["message"]);

        default:
          return json["value"];
      }
    } else { // Everything else is a Blob ?!
      return new http.Blob(content: body, mimetype: response.headers["content-type"]);
    }
  }
}