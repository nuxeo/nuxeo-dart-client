import 'package:unittest/html_enhanced_config.dart';
import 'package:nuxeo_automation/browser_client.dart' as nuxeo;

import 'tck.dart' as TCK;

main() {
  useHtmlEnhancedConfiguration();

  TCK.run(new nuxeo.Client());
}

