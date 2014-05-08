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
  Map<String, String> _headers = {};
  set(name, value) => _headers[name] = value;
  get asMap => _headers;
}

class Request extends base.Request {
  Headers headers = new Headers();
  bool withCredentials = false;
  String method;
  Uri _uri;

  Request(this.method, this._uri, {String username, String password}) {
    LOG.finest("$method $_uri");

    headers.set("Accept", "*/*"); // explicitly set the accept header to make FF work
    // Set the basic auth header
    if (username != null && password != null) {
      headers.set(base.HEADER_AUTHORIZATION, 'Basic ' + html.window.btoa("$username:$password"));
      withCredentials = true;
    }
  }

  // TODO(nfgs) - Fix this!
  get upload => null;

  Future<Response> send([data]) {
    var sendData = data;

    // Convert to html.FormData and html.Blob
    if (data is base.MultipartFormData) {
      var formData = new html.FormData();
      data.data.forEach((k, v) {
        if (v is base.Blob) {
          var blob = new html.Blob([v.content], v.mimetype);
          formData.appendBlob(k, blob, v.filename);
        }
      });
      sendData = formData;
    } else if (data is base.Blob) {
      sendData = data.content;
    }

    return html.HttpRequest.request(
        _uri.toString(),
        method: method,
        withCredentials: withCredentials,
        requestHeaders: headers.asMap,
        sendData: sendData)
    .then((request) => new Response(request.response, request.responseHeaders))
    .catchError((e) {
      var request = e.currentTarget;
      throw new base.ClientException(e.target.responseText, request: this, response: new Response(request.response, request.responseHeaders));
    });
  }
}

class Client extends base.Client {
  /// [username] and [password] for authentication
  /// [url] is the base URL to be used with the credentials
  Client({String username, String password, String url}) : super(username: username, password: password, url: url);
  Request method(String method, Uri uri, {bool multipart:false}) => new Request(method, uri, username: username, password: password);
}

