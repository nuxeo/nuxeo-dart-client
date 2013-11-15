part of nuxeo_client;

/**
 * [Operation] is the Nuxeo Automation Operation model.
 */
class Operation {
  String id;
  String label;
  String category;
  String requires;
  String description;
  String url;
  Map<String, OperationParam> params;

  Operation._internal();

  factory Operation.fromJSON(Map<String, Object> json) {

    var params = new Map<String, OperationParam>();
    (json["params"] as List).forEach((p) {
      var param = new OperationParam.fromJSON(p);
      params[param.name] = param;
    });

    return new Operation._internal()
    ..id = json["id"]
    ..label = json["label"]
    ..description = json["description"]
    ..category = json["category"]
    ..requires = json["requires"]
    ..url = json["url"]
    ..params = params;
  }

  OperationParam operator [](String key) => params[key];

}

/**
 * [OperationParam] is the model for a parameter in a Nuxeo Automation Operation.
 */
class OperationParam {

  String name;

  String type; // the data type

  String widget; // the widget type

  List<String> values; // the default values

  bool isRequired;

  num order;

  OperationParam();

  factory OperationParam.fromJSON(Map<String, Object> json)
   => new OperationParam()
    ..name = json["name"]
   ..type = json["type"]
   ..isRequired = json["required"]
   ..widget = json["widget"]
   ..values = json["values"]
   ..order = json["order"];

  toString() => "$name [$type] ${isRequired ? "required" : "optional"}";
}