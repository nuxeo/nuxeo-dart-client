part of nuxeo;

class Document {

  String repository;
  String uid;
  String path;
  String type;
  String state;
  String versionLabel;
  List<String> facets;

  Map<String, dynamic> properties = {};

  Document._internal(json) :
    repository = json["repository"],
    uid = json["uid"],
    path = json["path"],
    type = json["type"],
    state = json["state"],
    versionLabel = json["versionLabel"],
    facets = json["facets"] {

    if (json.containsKey("properties")) {
      json["properties"].forEach((k, v) { properties[k] = v; });
    }
  }

  factory Document.fromJSON(json) => new Document._internal(json);


  operator[]= (key, value) {
    if (key is List) {
      for (var i = 0; i < key.length; i++) {
        this[key[i]] = value[i];
      }
    }
    properties[key] = value;
  }

  operator[] (key) {
    if (key is List) {
      return key.map((k) => this[k]).toList();
    }
    return properties[key];
  }

}

class PaginableDocuments { //implements Iterable<Document> {

  Iterable<Document> docs;
  int totalSize,
      pageIndex,
      pageSize,
      pageCount;

  PaginableDocuments(this.docs);

  int get length => docs.length;
}
