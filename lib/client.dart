/**
 * Provides a Nuxeo Client Library.
 *
 * ## Installing ##
 *
 * Use [pub][] to install this package. Add the following to your `pubspec.yaml`
 * file.
 *
 *     dependencies:
 *       nuxeo_automation: any
 *
 * Then run `pub install`.
 *
 * ## Quick Start ##
 *
 *
 * This library should not be imported directly.
 * You should use either `browser_client` or `standalone_client`
 * as these provide proper abstractions (see [http_client](http_client.html)).
 *
 * * For browser applications use:
 *
 *     `import 'package:nuxeo_automation/browser_client.dart' as nuxeo_automation;`
 *
 * * For standalone/console applications use:
 *
 *     `import 'package:nuxeo_automation/standalone_client.dart' as nuxeo_automation;`
 *
 * * Then create your [Client] instance:
 *
 *     `var nx = new nuxeo_automation.Client();`
 *
 *
 * For more information, see the
 * [nuxeo_automation package on pub.dartlang.org](http://pub.dartlang.org/packages/nuxeo_automation).
 *
 * [pub]: http://pub.dartlang.org
 */
library nuxeo_client;

import 'dart:async';
import 'dart:collection';
import 'dart:math' as Math;
import 'dart:convert' show JSON;
import 'package:logging/logging.dart';
import 'http.dart' as http;
import 'rest.dart' as rest;
export 'rest.dart' show RemoteDocument;
import 'automation.dart' as rpc;

part 'src/login.dart';
part 'src/request.dart';
part 'src/operation.dart';
part 'src/uploader.dart';
part 'src/registry.dart';
part 'src/document.dart';

/**
 * [Automation] client.
 */
abstract class Client {

  static final LOG = new Logger("nuxeo.automation");

  /// The [http.Client] to use
  http.Client httpClient;

  Uri _rpcUri, _restUri;

  Client(this.httpClient, String url) {
    _rpcUri = Uri.parse(url + "/site/automation");
    _restUri = Uri.parse(url + "/api/v1");
  }

  /* REST */
  rest.Request doc(String uidOrPath, {String repo}) {
    var path;
    if (uidOrPath.startsWith("/")) {
      if (uidOrPath.endsWith("/")) {
        uidOrPath = uidOrPath.substring(0, uidOrPath.length - 1);
      }
      path = "path$uidOrPath";
    } else {
      path = "id/$uidOrPath";
    }
    return new rest.Request(Uri.parse("$_restUri/$path"), this, repo: repo);
  }

  rest.Request user(String userId, {String repo}) =>
      new rest.Request(Uri.parse("$_restUri/user/$userId"), this, repo: repo);

  rest.Request group(String groupId, {String repo}) =>
      new rest.Request(Uri.parse("$_restUri/group/$groupId"), this, repo: repo);

  rest.Request directory(String directoryId, {String repo}) =>
      new rest.Request(Uri.parse("$_restUri/directory/$directoryId"), this, repo: repo);

  /* RPC */

  /// Creates an [OperationRequest] for the [Operation] with the given [id].
  ///
  /// You can also specify an [execTimeout] and an [uploadTimeout].
  rpc.OperationRequest op(String id, {
    execTimeout: const Duration(seconds: 30),
    uploadTimeout: const Duration(minutes: 20)
  }) => new rpc.OperationRequest(id, _rpcUri, this,
      execTimeout: execTimeout,
      uploadTimeout: uploadTimeout);

  Future<OperationRegistry> get registry => OperationRegistry.get(_rpcUri, httpClient);

  /// Logs in to the Nuxeo server and returns a [Login]
  Future<Login> get login => rpc.login(_rpcUri, httpClient);

}

/**
 * Exception thrown when a [Request] throws an error
 */
class ClientException implements Exception {
  /**
   * A message describing the error.
   */
  final String message;

  /**
   * Creates a new ClientException with an optional error [message].
   */
  const ClientException([this.message = ""]);

  String toString() => "ClientException: $message";
}
