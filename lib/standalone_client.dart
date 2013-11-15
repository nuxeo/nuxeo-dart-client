library nuxeo_client_standalone;

import 'client.dart' as nx;
export 'client.dart';
import 'http/standalone.dart' as http;

class Client extends nx.Client {

  Client({
    String url : "http://localhost:8080/nuxeo",
    String username : "Administrator",
    String password : "Administrator",
    String realm : "default"}) :
    super(new http.Client(url,
        username: username,
        password: password,
        realm: realm), url);

}

