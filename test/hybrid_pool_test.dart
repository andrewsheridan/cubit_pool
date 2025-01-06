import 'dart:async';

import 'package:cubit_pool/hybrid_pool.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'animal.dart';
import 'mocks/mock_collection_reference.dart';
import 'mocks/mock_firebase_auth.dart';
import 'mocks/mock_firebase_firestore.dart';
import 'mocks/mock_hydrated_cubit_pool.dart';
import 'mocks/mock_query_snapshot.dart';
import 'mocks/mock_user.dart';

void main() {
  late MockHydratedCubitPool<Animal> localPool;
  late MockFirebaseAuth firebaseAuth;
  late MockFirebaseFirestore firestore;
  late StreamController<User?> userStreamController;
  late MockCollectionReference collectionReference;

  const uid = "User ID";

  const bear = Animal(
    id: "0",
    name: "Bear",
    count: 1,
  );

  const deer = Animal(
    id: "1",
    name: "Deer",
    count: 3,
  );

  setUp(() {
    localPool = MockHydratedCubitPool<Animal>();
    firebaseAuth = MockFirebaseAuth();
    firestore = MockFirebaseFirestore();
    userStreamController = StreamController<User?>();
    collectionReference = MockCollectionReference();

    when(() => localPool.state).thenReturn({
      bear.id: bear,
    });

    when(() => localPool.itemFromJson(any())).thenAnswer(
      (invocation) => Animal.fromMap(invocation.positionalArguments.first),
    );
    when(() => localPool.getItemID(deer)).thenAnswer(
      (invocation) => deer.id,
    );

    when(() => firestore.collection("$uid/animals"))
        .thenReturn(collectionReference);

    final querySnapshot = MockQueryDocumentSnapshot();
    when(() => querySnapshot.data()).thenReturn(
      deer.toMap(),
    );

    final snapshot = MockQuerySnapshot();

    when(() => snapshot.docs).thenReturn([querySnapshot]);
    when(() => collectionReference.get()).thenAnswer((_) async => snapshot);
    when(() => firebaseAuth.userChanges()).thenAnswer(
      (_) => userStreamController.stream,
    );
  });

  HybridPool<Animal> build() => HybridPool<Animal>(
        localPool: localPool,
        auth: firebaseAuth,
        firestore: firestore,
        collectionPath: (user) => "${user.uid}/animals",
      );

  test(
    "Given there is no user logged in, when constructed, expose data from HydratedCubit.",
    () async {
      when(() => firebaseAuth.currentUser).thenReturn(null);

      final pool = build();
      await pumpEventQueue();

      expect(pool.getByID(bear.id), bear);
    },
  );

  test(
    "Given there is an anonymous user logged in, when constructed, expose data from HydratedCubit.",
    () async {
      final user = MockUser();
      when(() => user.isAnonymous).thenReturn(true);
      when(() => firebaseAuth.currentUser).thenReturn(user);

      final pool = build();
      await pumpEventQueue();

      expect(pool.getByID(bear.id), bear);
    },
  );

  test(
    "Given there is a non-anon user signed in, when constructed, expose data from Firebase.",
    () async {
      final user = MockUser();
      when(() => user.isAnonymous).thenReturn(false);
      when(() => user.uid).thenReturn(uid);
      when(() => firebaseAuth.currentUser).thenReturn(user);

      final pool = build();
      await pumpEventQueue();

      expect(pool.getByID(deer.id), deer);
      expect(pool.getByID(bear.id), null);
    },
  );

  test(
    "Given there is no user logged in, when a non-anon user signs in, then copy HydratedCubit data to Firebase and delete it from HydratedCubit.",
    () async {},
  );

  test(
    "Given there is an anonymous user logged in, when a non-anon user signs in, then copy HydratedCubit data to Firebase and delete it from HydratedCubit.",
    () async {},
  );

  test(
    "Given there is a non-anon user signed in, when the user signs out, then switch to exposing HydratedCubit data.",
    () async {},
  );

  // TODO: Should I keep the local data exposed if the firebase transfer fails?
  test(
    "Given there is no user logged in, when a non-anon user signs in and Firebase data copy fails, do not delete HydratedCubit data.",
    () async {},
  );

  // TODO: Maybe I make two versions of the HybridPool, one that listens to the source for changes, and one that is the source of truth that can be manually refreshed.
  test(
    "Given there is no user logged in, when the local HydratedCubit data changes, call notifyListeners().",
    () async {},
  );

  test(
    "Given there is an anonymous user logged in, when the local HydratedCubit data changes, call notifyListeners().",
    () async {},
  );

  test(
    "Given there is a non-anon user logged in, when the  data changes, call notifyListeners().",
    () async {},
  );

  // TODO: Unit tests for upserting

  // TODO: Unit tests for deleting

  // TODO: Unit tests for refresh
}
