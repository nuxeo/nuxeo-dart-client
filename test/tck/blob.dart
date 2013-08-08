part of tck;

void testBlobs(nuxeo.Client nx) {
  group('Direct Blob upload', () {

    nuxeo.Document root;

    test('Create root', () {
      nx.op("Document.Create")(
          input:"doc:/",
          params: {
            "type" : "Folder",
            "name" : "TestBlobs",
            "properties" : "dc:title=Test Blobs \ndc:description=Simple container"
          })
      .then(expectAsync1((nuxeo.Document doc) {
        expect(doc.uid, isNotNull);
        root = doc;
      }));
    });

    test('Create Blob1 (txt)', () {
      var blob = new http.Blob(
          content: "some content in plain text",
          mimetype: "text/plain",
          filename: "testMe.txt");

      nx.op("FileManager.Import")(
          input: blob,
          context: {
            "currentDocument": root.path
          })
      .then(expectAsync1((nuxeo.Document doc) {
        expect(doc.type, equals("Note"));
      }));
    });

    test('Create Blob2 (bin)', () {
      var blob = new http.Blob(
          content: "some fake bin content",
          mimetype: "application/something",
          filename: "testBin.bin");

      nx.op("FileManager.Import")(
          input: blob,
          context: {
            "currentDocument": root.path
          })
      .then(expectAsync1((nuxeo.Document doc) {
        expect(doc.type, equals("File"));
      }));
    });

    test('Read children', () {
      nx.op("Document.GetChildren")(
          input: "doc:${root.path}"
       )
      .then(expectAsync1((Iterable<nuxeo.Document> docs) {
        expect(docs, hasLength(2));
      }));
    });

  });

  group('Batch Blob upload', () {

    nuxeo.Document root;

    test('Create root', () {
      nx.op("Document.Create")(
          input:"doc:/",
          params: {
            "type" : "Folder",
            "name" : "TestBlobs",
            "properties" : "dc:title=Test Blobs Batch \ndc:description=Simple container"
          })
      .then(expectAsync1((nuxeo.Document doc) {
        expect(doc.uid, isNotNull);
        root = doc;
      }));
    });

    var op = nx.op("FileManager.Import");

    test('Create Blob1 (txt)', () {
      var blob = new http.Blob(
          content: "some content in plain text",
          mimetype: "text/plain",
          filename: "testMe.txt");

      op.uploader.uploadFile(blob)
      .then(expectAsync1((nuxeo.Upload upload) {
        expect(upload.fileIndex, equals(0));
      }));
    });

    test('Create Blob2 (bin)', () {
      var blob = new http.Blob(
          content: "some fake bin content",
          mimetype: "application/something",
          filename: "testBin.bin");

      op.uploader.uploadFile(blob)
      .then(expectAsync1((nuxeo.Upload upload) {
        expect(upload.fileIndex, equals(1));
      }));
    });

    test('Do import', () {
      var blob = new http.Blob(
          content: "some fake bin content",
          mimetype: "application/something",
          filename: "testBin.bin");

      op(context : {
        "currentDocument" : root.path
      })
      .then(expectAsync1((Iterable<nuxeo.Document> docs) {
        expect(docs, hasLength(2));
      }));
    });

    test('Read children', () {
      nx.op("Document.GetChildren")(
          input: "doc:${root.path}"
       )
      .then(expectAsync1((Iterable<nuxeo.Document> docs) {
        expect(docs, hasLength(2));
      }));
    });

  });
}