library nuxeo_automation_standalone;

import 'automation.dart' as automation;
export 'automation.dart';
import 'http/standalone.dart' as http;

class Client extends automation.Client {

  Client({
    String url : "http://localhost:8080/nuxeo/site/automation",
    String username : "Administrator",
    String password : "Administrator",
    String realm : "default"}) :
    super(new http.Client(url,
        username: username,
        password: password,
        realm: realm), url);

}

