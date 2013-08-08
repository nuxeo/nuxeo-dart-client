/**
 * Provides a Nuxeo Automation Client Library.
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
 */
library nuxeo_automation;

import 'dart:async';
import 'dart:collection';
import 'dart:math' as Math;
import 'dart:json' as JSON;
import 'package:logging/logging.dart';
import 'http.dart' as http;

part 'src/request.dart';
part 'src/operation.dart';
part 'src/uploader.dart';
part 'src/registry.dart';
part 'src/document.dart';

/**
 * [Automation] client.
 */
class Automation {

  static final LOG = new Logger("nuxeo.automation");

  /// The [http.Client] to use
  http.Client client;

  Uri uri;

  Automation(this.client, [String url = "http://localhost:8080/nuxeo/site/automation"]) {
    uri = Uri.parse(url);
  }

  /// Creates an [OperationRequest] for the [Operation] with the given [id].
  /// You can also specify an [execTimeout] and an [uploadTimeout].
  OperationRequest op(String id, {
    execTimeout: const Duration(seconds: 30),
    uploadTimeout: const Duration(minutes: 20)
  }) => new OperationRequest(id, uri, client,
      execTimeout: execTimeout,
      uploadTimeout: uploadTimeout);

  Future<OperationRegistry> get registry => OperationRegistry.get(uri, client);

}

/**
 * Exception thrown when an [OperationRequest] throws an error
 */
class AutomationException implements Exception {
  /**
   * A message describing the error.
   */
  final String message;

  /**
   * Creates a new AutomationException with an optional error [message].
   */
  const AutomationException([this.message = ""]);

  String toString() => "AutomationException: $message";
}
