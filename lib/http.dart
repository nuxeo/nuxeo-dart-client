library http;

import 'dart:uri';
import 'dart:async';

const HEADER_CONTENT_TYPE = "content-type";

abstract class Response {
  Future get body;
}

abstract class RequestHeaders {
  set(name, value);
}

abstract class Request {
  get headers;
  Future<Response> send([data]);
}

abstract class Client {
  Uri uri;
  String realm;

  Future<Request> getUrl(Uri uri);
  Future<Request> postUrl(Uri uri);
}