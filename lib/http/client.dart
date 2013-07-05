library http_client;

import 'dart:html' as html;
import 'dart:utf';
import 'dart:async';
import 'package:nuxeo/http.dart' as base;

class Response implements base.Response {
  Object response;
  Response(this.response);
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
      if (request.readyState == html.HttpRequest.DONE &&
          (request.status == 200)) {
        completer.complete(new Response(request.response));
      }
    });
    request.onError.listen((e) {
      completer.completeError(new Exception(e));
    });

    // Convert to html.FormData and html.Blob
    if (data is base.MultipartFormData) {
      var formData = new html.FormData();
      data.data.forEach((k, v) {
        if (v is base.Blob) {
          var blob = new html.Blob([decodeUtf8(v.content)], v.mimetype);
          formData.append(k, blob, v.filename);
        }
      });
      request.send(formData);
    } else if (data is base.Blob) {
      request.send(decodeUtf8(data.content));
    } else {
      request.send(data);
    }
    return completer.future;
  }
}

class Client implements base.Client {

  Request get(Uri uri) => new Request('GET', uri);

  Request post(Uri uri, {bool multipart:false}) => new Request('POST', uri);
}

