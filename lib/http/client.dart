library http_client;

import 'dart:html';
import 'dart:uri';
import 'dart:async';
import 'package:nuxeo/http.dart' as http;

class Response implements http.Response {
  Object response;
  Response(this.response);
  Future get body => new Future.sync(() => response);
}

class Headers implements http.RequestHeaders {
  HttpRequest request;
  Headers(this.request);
  set(name, value) => request.setRequestHeader(name, value);
}

class Request implements http.Request {
  HttpRequest request;

  Request(String method, Uri uri) {
    request = new HttpRequest()
    ..open(method, uri.toString(), async: true)
    ..withCredentials = true;
  }

  get headers => new Headers(request);

  Future<Response> send([data]) {
    var completer = new Completer<Response>();
    request.onReadyStateChange.listen((e) {
      if (request.readyState == HttpRequest.DONE &&
          (request.status == 200 || request.status == 0)) {
        completer.complete(new Response(request.response));
      }
    });
    request.send(data);
    return completer.future;
  }
}

class Client implements http.Client {
  Uri uri;
  String realm;

  Client([String url = "http://localhost:8080/nuxeo/site/automation"]) {
    uri = Uri.parse(url);
  }

  Future<Request> getUrl(Uri uri) => new Future.sync(() => new Request('GET', uri));

  Future<Request> postUrl(Uri uri) => new Future.sync(() => new Request('POST', uri));
}

