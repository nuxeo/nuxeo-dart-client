part of tck;

_cleanup(json) => json.replaceAll("\n", "").replaceAll("\r", "");

void testMarshalling(nuxeo.Client nx) {
  group('Marshaling Extensions', () {

    group('Manage Complex Properties', () {

      var creationFieldsJSON, updateFieldsJSON;

      setUp(() => Future.wait([
        getResource("test/resources/creationFields.json").then((json){ creationFieldsJSON = _cleanup(json); }),
        getResource("test/resources/updateFields.json").then((json){ updateFieldsJSON = _cleanup(json); })]
      ));

      var testDoc;

      test("Create a File", () {

        var creationProps = {
          "ds:tableName": "MyTable",
          "ds:attachments": ["att1", "att2", "att3"],
          "ds:fields": creationFieldsJSON,
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

      /*
      test("Update the document", () {
        nx.op("Document.Update")(
            input: "doc:${testDoc.path}",
            params: {
              "properties": {
                "ds:fields": fieldsDataAsJSon
              }
            }
        )
        .then(expectAsync1((nuxeo.Document doc) {
          expect(doc.uid, isNotNull);
        }));
      });
      */

    });
  });
}