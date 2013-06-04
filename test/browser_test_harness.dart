import 'package:unittest/html_enhanced_config.dart';
import 'package:nuxeo/http/client.dart' as http;

import '_test_runner.dart';

main() {
  useHtmlEnhancedConfiguration();

  runTests(new http.Client());
}

