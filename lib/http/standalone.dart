library standalone_client;

import 'dart:io';
import 'dart:async';
import 'dart:json' as JSON;
import 'package:nuxeo/http.dart' as http;

class Response implements http.Response {
  HttpClientResponse response;
  Response(this.response);

  Future get body {
    var completer = new Completer();
    StringBuffer body = new StringBuffer();
    response.listen(
        (data) => body.write(new String.fromCharCodes(data)),
        onDone: () {
          completer.complete(body.toString());
        }
    );
    return completer.future;
  }
}

class Request implements http.Request {
  HttpClientRequest request;
  Request(this.request);

  get headers => request.headers;

  Future<Response> send([data]) {
    if (?data) request.write(data);
    return request.close().then((response) => new Response(response));
  }

}

class Client implements http.Client {
  HttpClientCredentials credentials;
  Uri uri;
  String realm;

  Client([
      String url = "http://localhost:8080/nuxeo/site/automation",
      String username = "Administrator",
      String password = "Administrator",
      this.realm = "default"]) {
    uri = Uri.parse(url);
    credentials = new HttpClientBasicCredentials(username, password);
  }

  HttpClient get _httpClient => new HttpClient()..addCredentials(uri, realm, credentials);

  Request _wrap(request) => new Request(request);

  Future<Request> getUrl(Uri uri) =>  _httpClient.getUrl(uri).then(_wrap);
  Future<Request> postUrl(Uri uri) => _httpClient.postUrl(uri).then(_wrap);
}

