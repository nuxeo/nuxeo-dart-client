import 'dart:html';
import 'package:unittest/html_enhanced_config.dart';
import 'package:nuxeo_automation/browser_client.dart' as nuxeo;

import 'tck.dart' as TCK;

main() {
  useHtmlEnhancedConfiguration();
  TCK.getResource = (String filename) => HttpRequest.getString(filename);

  var nx = new nuxeo.Client();

  nx.login
    .catchError((e) =>
        document.body.append(new Element.tag("div")..text = "Error: ${e.message}"))
     .then((_) => TCK.run(nx));
}

