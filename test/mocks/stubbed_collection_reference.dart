import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';

import 'mock_document_reference.dart';
import 'mock_query_snapshot.dart';

// ignore: subtype_of_sealed_class
class StubbedCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {
  final Map<String, dynamic> _map = {};

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    final snapshot = MockQuerySnapshot();
    final docs = <MockQueryDocumentSnapshot>[];
    for (final value in _map.values) {
      docs.add(MockQueryDocumentSnapshot(getData: () => value));
    }
    when(() => snapshot.docs).thenReturn(docs);
    return snapshot;
  }

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    final reference = MockDocumentReference();

    when(() => reference.set(any())).thenAnswer((invocation) async {
      final data = invocation.positionalArguments.first;

      if (path == null) {
        _map.clear();
        _map.addAll(data);
      } else {
        _map[path] = data;
      }
    });

    when(() => reference.get()).thenAnswer((invocation) async {
      final snapshot = MockQueryDocumentSnapshot(getData: () => _map[path]);
      return snapshot;
    });

    return reference;
  }
}
