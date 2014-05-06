part of tck;

void testCRUD(nuxeo.Client nx) {

  nuxeo.Document root;
  List<nuxeo.Document> children = [];

  group('Create and read docs', () {

    test('Create root', () =>
      nx.op("Document.Create")
      .input("doc:/")
      .params({
            "type" : "Folder",
            "name" : "TestDocs",
            "properties" : "dc:title=Test Docs \ndc:description=Simple container"
       })
      .call()
      .then(expectAsync((nuxeo.Document doc) {
        expect(doc.uid, isNotNull);
        root = doc;
      }))
    );

    test('Create first child', () {

      expect(root, isNotNull);

      return nx.op("Document.Create")
          .input("doc:${root.path}")
          .params({
            "type" : "File",
            "name" : "TestFile1",
          })
          .call()
      .then(expectAsync((nuxeo.Document doc) {
        expect(doc.uid, isNotNull);
        expect(doc.path.startsWith(root.path), isTrue);
        children.add(doc);
      }));
    });

    test('Create second child', () {

      expect(root, isNotNull);

      return nx.op("Document.Create")
          .input("doc:${root.path}")
          .params({
            "type" : "File",
            "name" : "TestFile2",
          })
          .call()
      .then(expectAsync((nuxeo.Document doc) {
        expect(doc.uid, isNotNull);
        expect(doc.path.startsWith(root.path), isTrue);
        children.add(doc);
      }));
    });

    test('Update second child', () {

      expect(children.length, isNonZero);

      nx.op("Document.Update")
          .input("doc:${children[1].path}")
          .params({
            "save" : "true",
            "properties" : "dc:description=Simple File\ndc:subjects=subject1,subject2",
          })
          .call()
      .then(expectAsync((nuxeo.Document doc) {
        expect(doc['dc:description'], equals("Simple File"));
        expect(doc['dc:subjects'], hasLength(2));
      }));
    });

    test('Read children', () {

      expect(root, isNotNull);

      nx.op("Document.GetChildren")
      .input("doc:${root.path}")
      .call()
      .then(expectAsync((Iterable<nuxeo.Document> docs) {
        expect(docs, hasLength(2));
      }));
    });

  });


}