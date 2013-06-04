part of nuxeo;

class OperationRequest {
  http.Client client;

  String opId;

  OperationRequest(this.opId, this.client);

  call([Map<String, Object> ctx]) => OperationRegistry.get(client.uri, client).then((registry) {
      var op = registry[opId];
      if (op == null) {
        throw new ArgumentError("No such operation: $opId");
      }

      // Setup the parameters
      var params = {};
      if (?ctx) {
        ctx.forEach((key, value) {
          var param = op[key];
          if (param == null) {
            throw new ArgumentError("No such parameter '$key' for operation ${op.id}.");
          }
          if (value != null) {
            params[key] = value;
          }
        });
      }

      var opUri = Uri.parse(client.uri.toString() + "/$opId");

      var completer = new Completer();

      client
      .postUrl(opUri)
      .then((http.Request request) {
        var json = JSON.stringify({"params":params});
        request.headers.set(http.HEADER_CONTENT_TYPE, CTYPE_REQUEST_NOCHARSET);
        return request.send(json);
      })
      .then((http.Response response) => response.body)
      .then((body) {
        completer.complete(JSON.parse(body));
      });

      return completer.future;
    });

}