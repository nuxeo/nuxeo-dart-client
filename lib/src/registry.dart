part of nuxeo;

Future<bool> authenticateFn(Uri url, String scheme, String realm) {

}

class OperationRegistry {
  Map<String, String> paths;
  Map<String, Operation> ops;
  Map<String, Operation> chains;

  static Map<Uri, OperationRegistry> _registries = new Map<Uri, OperationRegistry>();

  static Future<OperationRegistry> get(Uri uri, [http.Client client]) {
    if (_registries.containsKey(uri)) {
      return new Future.value(_registries[uri]);
    } else {
      var request = client.get(uri)..headers.set("Accept", CTYPE_AUTOMATION);
      return request.send()
      .then((http.Response response) {
        var body = response.body,
            json = JSON.parse(body);
        _registries[uri] = new OperationRegistry.fromJSON(json);
        return _registries[uri];
      });
    }
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