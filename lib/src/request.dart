part of nuxeo_client;

const CTYPE_AUTOMATION = "application/json+nxautomation";
const CTYPE_ENTITY = "application/json+nxentity";
const CTYPE_JSON = "application/json";
const CTYPE_REQUEST_NOCHARSET = "application/json+nxrequest";
const CTYPE_MULTIPART_RELATED = "multipart/related";
const CTYPE_MULTIPART_MIXED = "multipart/mixed";
const CTYPE_REQUEST = "application/json+nxrequest; charset=UTF-8";
const KEY_ENTITY_TYPE = "entity-type";
const HEADER_NX_SCHEMAS = "X-NXproperties";
const HEADER_NX_VOIDOP = "X-NXVoidOperation";
const HEADER_NX_TX_TIMEOUT = "Nuxeo-Transaction-Timeout";
const HEADER_NX_REPOSITORY = "X-NXRepository";
const HEADER_NX_VERSIONING_OPTION = "X-Versioning-Option";
const HEADER_NX_FETCH_DOCUMENT = "X-NXfetch.document";
const HEADER_NX_FETCH_DEPTH = "depth";
const HEADER_NX_ENRICHERS = "X-NXenrichers.document";

abstract class BaseRequest {

  static final Logger LOG = new Logger("nuxeo.client.request");

  Client nxClient;
  Uri uri;

  Map headers;

  // Hold this data for debugging
  http.Request request;
  var requestData;

  BatchUploader _batchUploader;

  BaseRequest(this.uri, this.nxClient) {
    headers = new Map.from(nxClient.headers);
    timeout = nxClient.timeout;
    schemas = nxClient.schemas;
    repository = nxClient.repository;
  }

  http.Client get httpClient => nxClient.httpClient;

  get schemas => headers[HEADER_NX_SCHEMAS].split(",");
  set schemas(List<String> s) {
    if (s.isNotEmpty) {
      headers[HEADER_NX_SCHEMAS] = s.join(",");
    }
  }

  get repository => headers[HEADER_NX_REPOSITORY];
  set repository(String r) {
    headers[HEADER_NX_REPOSITORY] = r;
  }

  get enrichers => headers[HEADER_NX_ENRICHERS].split(",");
  set enrichers(List<String> s) {
    if (s.isEmpty) {
      headers.remove(HEADER_NX_ENRICHERS);
    } else {
      headers[HEADER_NX_ENRICHERS] = s.join(",");
    }
  }

  get timeout => new Duration(seconds: int.parse(headers[HEADER_NX_TX_TIMEOUT]));
  set timeout(Duration t) {
    headers[HEADER_NX_TX_TIMEOUT] = t.inSeconds.toString();
  }

  get voidOp => headers[HEADER_NX_VOIDOP] == "true";
  set voidOp(bool f) {
    if (f) {
      headers[HEADER_NX_VOIDOP] = f.toString();
    } else {
      headers.remove(HEADER_NX_VOIDOP);
    }
  }

  get versioningOption => headers[HEADER_NX_VERSIONING_OPTION];
  set versioningOption(String option) {
    if (option == "NONE") {
      headers.remove(HEADER_NX_VERSIONING_OPTION);
    } else {
      headers[HEADER_NX_VERSIONING_OPTION] = option;
    }
  }

  get fetchDocument => headers[HEADER_NX_FETCH_DOCUMENT];
  set fetchDocument(String parts) {
    headers[HEADER_NX_FETCH_DOCUMENT] = parts;
  }

  get fetchDepth => int.parse(headers[HEADER_NX_FETCH_DEPTH]);
  set fetchDepth(int depth) {
    headers[HEADER_NX_FETCH_DEPTH] = depth.toString();
  }

  setRequestHeaders() {
    // Set the request headers
    headers.forEach((k, v) {
      if (v != null) {
        request.headers.set(k, v);
      }
    });
  }

  /// Send the request
  Future<http.Response> execute([arguments]);

  /// Send the request and handle the response
  Future<http.Response> call([arguments]) =>
      execute(arguments)
      .then(handleResponse)
      .catchError((e) {
        throw new http.ClientException(e.message);
      });



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