library nuxeo_client_browser;

import 'client.dart' as nx;
export 'client.dart';
import 'http/client.dart' as http;

class Client extends nx.Client {

  Client({String url : "http://localhost:8080/nuxeo"}) :
    super(new http.Client(), url);

}

