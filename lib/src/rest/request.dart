part of nuxeo_rest_client;

class Request extends nx.Request {

  static final Logger LOG = new Logger("nuxeo.client.request");

  Map methods;

  Request(Uri uri, nx.Client client, {String repo, Duration execTimeout, Duration uploadTimeout}) :
        super(uri, client, repo:repo, execTimeout: execTimeout, uploadTimeout: uploadTimeout);

  fetch() => this(httpClient.get);
  create(content) => this(httpClient.post, content);
  update(content) => this (httpClient.put, content);
  delete() => this(httpClient.delete);

  call(method, [body]) {
    http.Request request = method(uri);
    setRequestHeaders(request);

    // Set the content type
    request.headers.set(http.HEADER_CONTENT_TYPE, nx.CTYPE_ENTITY);

    var requestData;
    if (body != null) {
      requestData = JSON.encode(body);
      LOG.finest("Body: $body");
    }

    return request
          .send(requestData)
          .catchError((e) {
            throw new nx.ClientException(e.message);
          })
          .then(handleResponse);
  }

  handleResponse(response) {
    var obj = super.handleResponse(response);

    if (obj is nx.Document) {
      return new RemoteDocument.wrap(obj, nxClient);
    }

    return obj;
  }

  /// All method calls with be used as adapters
  noSuchMethod(Invocation invocation) {
    String member = MirrorSystem.getName(invocation.memberName);
    if (invocation.isMethod) {
      var params = invocation.positionalArguments.join("");
      uri = Uri.parse("$uri/@$member/$params");
    }
  }

}