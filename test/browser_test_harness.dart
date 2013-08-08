import 'package:unittest/html_enhanced_config.dart';
import 'package:nuxeo_automation/http/client.dart' as http;

import 'tck.dart' as TCK;

main() {
  useHtmlEnhancedConfiguration();

  TCK.run(new http.Client());
}

