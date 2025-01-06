import 'dart:async';

import 'package:cubit_pool/hybrid_pool.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'animal.dart';
import 'mocks/mock_firebase_auth.dart';
import 'mocks/mock_firebase_firestore.dart';
import 'mocks/mock_hydrated_cubit_pool.dart';

void main() {
  late MockHydratedCubitPool<Animal> localPool;
  late MockFirebaseAuth firebaseAuth;
  late MockFirebaseFirestore firestore;
  late StreamController<User?> userStreamController;

  const bear = Animal(
    id: "0",
    name: "Bear",
    count: 1,
  );

  setUp(() {
    localPool = MockHydratedCubitPool<Animal>();
    firebaseAuth = MockFirebaseAuth();
    firestore = MockFirebaseFirestore();
    userStreamController = StreamController<User?>();

    when(() => localPool.state).thenReturn({
      bear.id: bear,
    });

    when(() => firebaseAuth.userChanges()).thenAnswer(
      (_) => userStreamController.stream,
    );
  });

  HybridPool<Animal> build() => HybridPool<Animal>(
        localPool: localPool,
        auth: firebaseAuth,
        firestore: firestore,
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
    () async {},
  );

  test(
    "Given there is a non-anon user signed in, when constructed, expose data from Firebase.",
    () async {},
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
