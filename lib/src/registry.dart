part of nuxeo;

Future<bool> authenticateFn(Uri url, String scheme, String realm) {

}

class OperationRegistry {
  Map<String, String> paths;
  Map<String, Operation> ops;
  Map<String, Operation> chains;

  static Map<Uri, OperationRegistry> _registries = null;

  static Future<OperationRegistry> get(Uri uri, [http.Client client]) {
    var completer = new Completer<OperationRegistry>();

    if (_registries == null) {
      _registries = new Map<Uri, OperationRegistry>();
    }

    String realm = "default";

    if (_registries.containsKey(uri)) {
      completer.complete(_registries[uri]);
    } else {
      client
      ..getUrl(uri)
      .then((http.Request request) {
        request.headers.set("Accept", CTYPE_AUTOMATION);
        return request.send();
      })
      .then((http.Response response) => response.body)
      .then((body) {
        var json = JSON.parse(body);
        _registries[uri] = new OperationRegistry.fromJSON(json);
        completer.complete(_registries[uri]);
      });
    }

    return completer.future;
  }

  OperationRegistry._internal(this.paths, this.ops, this.chains);

  factory OperationRegistry.fromJSON(Map<String, Object> json) {

    var paths = json["paths"];

    var ops = {};
    (json["operations"] as List).forEach((json) {
      var op = new Operation.fromJSON(json);
      ops[op.id] = op;
    });

    var chains = {};

    return new OperationRegistry._internal(paths, ops, chains);
  }

  getPath(String key) => paths[key];

  Operation operator[](String key) => ops.containsKey(key) ? ops[key] : chains[key];
}