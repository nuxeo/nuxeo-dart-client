library http_browser;

import 'dart:html' as html;
import 'dart:async';
import '../http.dart' as base;

final LOG = base.LOG;

class Response implements base.Response {
  Object response;
  Map<String, String> headers;
  Response(this.response, this.headers);
  get body => response;
}

class Headers implements base.RequestHeaders {
  html.HttpRequest request;
  Headers(this.request);
  set(name, value) => request.setRequestHeader(name, value);
}

class Request extends base.Request {
  html.HttpRequest request;

  Request(String method, Uri uri) {
    LOG.finest("$method $uri");
    request = new html.HttpRequest()
    ..open(method, uri.toString(), async: true)
    ..withCredentials = true
    ..setRequestHeader("Accept", "*/*"); // explicitly set the accept header to make FF work
  }

  get upload => request.upload;

  get headers => new Headers(request);

  Future<Response> send([data]) {
    var completer = new Completer<Response>();
    request.onReadyStateChange.listen((e) {
      if (request.readyState == html.HttpRequest.DONE) {
        if (request.status == 200) {
          completer.complete(new Response(request.response, request.responseHeaders));
        } else {
          completer.completeError(new Exception(request.statusText));
        }
      }
    });
    request.onError.listen((e) {
      completer.completeError(new Exception(request.statusText));
    });

    // Convert to html.FormData and html.Blob
    if (data is base.MultipartFormData) {
      var formData = new html.FormData();
      data.data.forEach((k, v) {
        if (v is base.Blob) {
          var blob = new html.Blob([v.content], v.mimetype);
          formData.appendBlob(k, blob, v.filename);
        }
      });
      request.send(formData);
    } else if (data is base.Blob) {
      request.send(data.content);
    } else {
      request.send(data);
    }
    return completer.future;
  }
}

class Client extends base.Client {

  Request method(String method, Uri uri, {bool multipart:false}) => new Request(method, uri);

}

