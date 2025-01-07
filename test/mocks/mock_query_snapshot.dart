// ignore_for_file: subtype_of_sealed_class

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {
  final Map<String, dynamic>? Function() getData;

  MockQueryDocumentSnapshot({required this.getData});

  @override
  Map<String, dynamic> data() => getData() ?? {};
}
