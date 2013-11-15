part of tck;

void testREST(nuxeo.Client nx) {

  nuxeo.RemoteDocument doc;

  group('REST tests', () {

    test('Fetch domain document', () =>
      nx.doc("/default-domain").fetch()
      .then(expectAsync1((nuxeo.RemoteDocument rdoc) {
        expect(rdoc.uid, isNotNull);
        doc = rdoc;
      }))
    );

    test('Update fetched document', () {
      expect(doc, isNotNull);

      var newSourceValue = 'automation-test-${new DateTime.now().millisecondsSinceEpoch}';

      doc.update({'dc:source': newSourceValue});

      expect(doc.changeSet, isNotNull, reason: "changeSet should return a minimal doc");
      expect(doc.changeSet.properties, isNotNull, reason: "changeSet should return a doc with non  empty properties");
      expect(doc.changeSet.properties['dc:source'], isNotNull, reason: "changeSet should contain an entry for dc:source");

      doc.save()
      .then(expectAsync1((nuxeo.Document doc) {
        expect(doc.uid, isNotNull);
        expect(doc.properties['dc:source'], equals(newSourceValue));
      }));
    });

  });
}