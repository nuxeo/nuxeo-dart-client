import 'dart:html';
import 'package:unittest/html_enhanced_config.dart';
import 'package:nuxeo_client/browser_client.dart' as nuxeo;

import 'tck.dart' as TCK;

main() {
  useHtmlEnhancedConfiguration();

  var url = "http://localhost:8080/nuxeo";
  var nx = new nuxeo.Client(url: url, schemas: ["dublincore", "file"]);

  nx.login()
    .catchError((e) {
        document.body.append(new Element.tag("div")..text = "Failed to login to Nuxeo at $url ${e.message}");
        return null;
    })
     .then((login) {
       if (login != null)
        TCK.run(nx);
     });
}

