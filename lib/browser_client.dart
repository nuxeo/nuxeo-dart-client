library nuxeo_automation_browser;

import 'automation.dart' as automation;
import 'http/client.dart' as http;

class Client extends automation.Client {

  Client({String url : "http://localhost:8080/nuxeo/site/automation"}) :
    super(new http.Client(), url);

}

