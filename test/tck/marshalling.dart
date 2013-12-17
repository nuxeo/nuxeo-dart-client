part of tck;

void testMarshalling(nuxeo.Client nx) {
  group('Marshaling Extensions', () {

    group('Manage Complex Properties', () {

      var testDoc;

      test("Create a File", () {

        var creationProps = {
          "ds:tableName": "MyTable",
          "ds:attachments": ["att1", "att2", "att3"],
          "ds:fields": JSON.encode(creationFieldsJSON),
          "dc:title": "testDoc"
        };

        var properties = new nuxeo.PropertyMap(creationProps).toString();

        return nx.op("Document.Create")(
            input:"doc:/",
            params: {
              "type" : "DataSet",
              "name" : "testDoc",
              "properties" : properties
        })
        .then(expectAsync1((nuxeo.Document doc) {
          expect(doc.uid, isNotNull);
          testDoc = doc;
        }));
      });


      test("Update the document", () {
        nx.op("Document.Update")(
            input: "doc:${testDoc.path}",
            params: {
              "properties": {
                "ds:fields": JSON.encode(updateFieldsJSON)
              }
            }
        )
        .then(expectAsync1((nuxeo.Document doc) {
          expect(doc.uid, isNotNull);
        }));
      });


    });
  });
}

var creationFieldsJSON = [
    {
        "fieldType": "string",
        "description": "desc field0",
        "roles": [
            "Decision",
            "Score"
        ],
        "name": "field0",
        "columnName": "col0",
        "sqlTypeHint": "whatever"
    },
    {
        "fieldType": "string",
        "description": "desc field1",
        "roles": [
            "Decision",
            "Score"
        ],
        "name": "field1",
        "columnName": "col1",
        "sqlTypeHint": "whatever"
    },
    {
        "fieldType": "string",
        "description": "desc field2",
        "roles": [
            "Decision",
            "Score"
        ],
        "name": "field2",
        "columnName": "col2",
        "sqlTypeHint": "whatever"
    },
    {
        "fieldType": "string",
        "description": "desc field3",
        "roles": [
            "Decision",
            "Score"
        ],
        "name": "field3",
        "columnName": "col3",
        "sqlTypeHint": "whatever"
    },
    {
        "fieldType": "string",
        "description": "desc field4",
        "roles": [
            "Decision",
            "Score"
        ],
        "name": "field4",
        "columnName": "col4",
        "sqlTypeHint": "whatever"
    }
];

var updateFieldsJSON = [
    {
        "fieldType":"string",
        "description":"desc fieldA",
        "name":"fieldA",
        "columnName":"colA",
        "sqlTypeHint":"whatever"
    },
    {
        "fieldType":"string",
        "description":"desc fieldB",
        "name":"fieldB",
        "columnName":"colB",
        "sqlTypeHint":"whatever"
    }
];