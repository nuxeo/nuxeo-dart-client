/**
 * Provides abstractions for an HTTP client for both client and server side uses.
 */
library http_client;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:logging/logging.dart';

final Logger LOG = new Logger("http");

const HEADER_CONTENT_TYPE = "content-type";

class MultipartFormData {
  Map<String, dynamic> data = {};
  append(String name, value) {
    data[name] = value;
  }
}

class Blob {
  String filename;
  Uint8List content;
  String mimetype;

  Blob({this.filename: "blob", content, this.mimetype}) {
    if (content is Uint8List) {
      this.content = content;
    } else if (content is String) {
      this.content = new Uint8List.fromList(UTF8.encode(content));
    } else if (content is List<int>) {
      this.content = new Uint8List.fromList(content);
    }
  }

  int get length => content.length;
}

abstract class Response {
  get body;
  get headers;
}

abstract class RequestHeaders {
  set(String name, String value);
}

abstract class RequestUpload {
}

class RequestEvent {
  String type;
  RequestEvent(this.type);
}

abstract class Request {
  RequestHeaders get headers;
  get upload;
  Future<Response> send([data]);
}

abstract class Client {
  Request method(String method, Uri uri, {bool multipart:false});
  Request get(Uri uri) => method("GET", uri);
  Request post(Uri uri, {bool multipart:false}) => method("POST", uri, multipart: multipart);
  Request put(Uri uri) => method("PUT", uri);
  Request delete(Uri uri) => method("DELETE", uri);
}