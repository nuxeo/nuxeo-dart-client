part of tck;

void testPagination(nuxeo.Client nx) {

  group('Pagination', () {

    nuxeo.Document root;
    List<nuxeo.Document> children = [];

    test('Create root', () {
      nx.op("Document.Create")(
          input:"doc:/",
          params: {
            "type" : "Folder",
            "name" : "TestPagination",
            "properties" : "dc:title=Test Pagination \ndc:description=Simple container"
          })
      .then(expectAsync1((nuxeo.Document doc) {
        expect(doc.uid, isNotNull);
        root = doc;
      }));
    });

    test('Create 3 child Files', () {
      for (var idx = 1; idx <= 3; idx++) {
        nx.op("Document.Create")(
            input:"doc:${root.path}",
            params: {
              "type" : "File",
              "name" : "TestFile$idx",
            })
            .then(expectAsync1((nuxeo.Document doc) {
              expect(doc.uid, isNotNull);
              expect(doc.path.startsWith(root.path), isTrue);
            }));
      }
    });

    test('Query for page 1', () {
      nx.op("Document.PageProvider")(
          params: {
            "query" : "select * from Document where ecm:parentId = ?",
            "pageSize" : 2,
            "page" : 0,
            "queryParams" : root.uid
          })
          .then(expectAsync1((nuxeo.PaginableDocuments docs) {
            expect(docs, hasLength(2));
            expect(docs.pageSize, equals(2));
            expect(docs.pageCount, equals(2));
            expect(docs.totalSize, equals(3));
          }));
    });

    test('Query for page 2', () {
      nx.op("Document.PageProvider")(
          params: {
            "query" : "select * from Document where ecm:parentId = ?",
            "pageSize" : 2,
            "page" : 1,
            "queryParams" : root.uid
          })
          .then(expectAsync1((nuxeo.PaginableDocuments docs) {
            expect(docs, hasLength(1));
            expect(docs.pageSize, equals(2));
            expect(docs.pageCount, equals(2));
            expect(docs.totalSize, equals(3));
          }));
    });
  });
}