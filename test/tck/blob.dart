part of tck;

void testBlobs(nuxeo.Client nx) {

  group('Direct Blob upload', () {

    nuxeo.Document root;

    test('Create root', () =>
      nx.op("Document.Create")
      .input("doc:/")
      .params({
            "type" : "Folder",
            "name" : "TestBlobs",
            "properties" : "dc:title=Test Blobs \ndc:description=Simple container"
          })
       .call()
      .then(expectAsync((nuxeo.Document doc) {
        expect(doc.uid, isNotNull);
        root = doc;
      }))
    );

    test('Create Blob1 (txt)', () {
      expect(root, isNotNull);
      var blob = new http.Blob(
          content: "some content in plain text",
          mimetype: "text/plain",
          filename: "testMe.txt");

      return nx.op("FileManager.Import")
          .input(blob)
          .context({
            "currentDocument": root.path
          })
          .call()
      .then(expectAsync((nuxeo.Document doc) {
        expect(doc.type, equals("Note"));
      }));
    });

    test('Create Blob2 (bin)', () {
      expect(root, isNotNull);
      var blob = new http.Blob(
          content: "some fake bin content",
          mimetype: "application/something",
          filename: "testBin.bin");

      return nx.op("FileManager.Import")
          .input(blob)
          .context({
            "currentDocument": root.path
          })
          .call()
      .then(expectAsync((nuxeo.Document doc) {
        expect(doc.type, equals("File"));
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


  group('Batch Blob upload', () {

    nuxeo.Document root;

    test('Create root', () =>
      nx.op("Document.Create")
      .input("doc:/")
      .params({
            "type" : "Folder",
            "name" : "TestBlobs",
            "properties" : "dc:title=Test Blobs Batch \ndc:description=Simple container"
       })
      .call()
      .then(expectAsync((nuxeo.Document doc) {
        expect(doc.uid, isNotNull);
        root = doc;
      }))
    );

    var op = nx.op("FileManager.Import");

    test('Create Blob1 (txt)', () {
      expect(root, isNotNull);
      var blob = new http.Blob(
          content: "some content in plain text",
          mimetype: "text/plain",
          filename: "testMe.txt");

      return op.uploader.uploadFile(blob)
      .then(expectAsync((nuxeo.Upload upload) {
        expect(upload.fileIndex, equals(0));
      }));
    });

    test('Create Blob2 (bin)', () {
      expect(root, isNotNull);
      var blob = new http.Blob(
          content: "some fake bin content",
          mimetype: "application/something",
          filename: "testBin.bin");

      return op.uploader.uploadFile(blob)
      .then(expectAsync((nuxeo.Upload upload) {
        expect(upload.fileIndex, equals(1));
      }));
    });

    test('Do import', () {
      expect(root, isNotNull);
      return op.context({
        "currentDocument" : root.path
      })
      .call()
      .then(expectAsync((Iterable<nuxeo.Document> docs) {
        expect(docs, hasLength(2));
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

  group('Batch Blob update', () {
    nuxeo.Document root;

    var op = nx.op("FileManager.Import");
    var child;
    var filename = "testMe.txt";

    test('Create root', () =>
      nx.op("Document.Create")
      .input("doc:/")
      .params({
            "type" : "Folder",
            "name" : "TestBlobsUpdate",
            "properties" : "dc:title=Test Blobs update via Batch \ndc:description=Simple container"
      })
      .call()
      .then(expectAsync((nuxeo.Document doc) {
        expect(doc.uid, isNotNull);
        root = doc;
      }))
    );

    test('Create Child1', () {
      expect(root, isNotNull);
      return nx.op("Document.Create")
          .input("doc:${root.path}")
          .params({
            "type" : "File",
            "name" : "TestFile1"
          })
          .call()
      .then(expectAsync((nuxeo.Document doc) {
        expect(doc.uid, isNotNull);
        child = doc;
      }));
    });

    test('Upload Blob Text', () {
      expect(root, isNotNull);
      var blob = new http.Blob(
          content: "some content in plain text",
          mimetype: "text/plain",
          // TODO(nfgs) - size : 26,
          filename: filename);

      return op.uploader.uploadFile(blob)
      .then(expectAsync((nuxeo.Upload upload) {
        expect(upload.fileIndex, equals(0));
      }));
    });


    test('Update Child', () {
      expect(root, isNotNull);

      var properties = {
        'dc:description': 'New Description',
        'file:content': {
          'upload-batch': op.uploader.batchId,
          'upload-fileId': '0',
          'type': 'blob'
        }
      };

      nx.op("Document.Update")
      .params({
          "save": "true",
          "properties": properties
      })
      .input("doc:${child.uid}")
      .call()
      .then(expectAsync((nuxeo.Document doc) {
        expect(doc.properties['dc:description'], properties['dc:description']);
        expect(doc.properties['file:content']['name'], filename);
      }));
    });

  });

}