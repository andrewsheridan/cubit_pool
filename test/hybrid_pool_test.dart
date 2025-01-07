import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'mocks/stubbed_collection_reference.dart';

enum UserType {
  loggedOut,
  anonymous,
  loggedIn,
}

void main() {
  late MockHydratedCubitPool<Animal> localPool;
  late MockFirebaseAuth firebaseAuth;
  late MockFirebaseFirestore firestore;
  late StreamController<User?> userStreamController;
  late CollectionReference<Map<String, dynamic>> collectionReference;

  const uid = "User ID";

  const delayDuration = Duration(milliseconds: 250);

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

  void setUpLocalPool(List<Animal> animals) {
    when(() => localPool.state).thenReturn({
      for (final animal in animals) animal.id: animal,
    });
  }

  User? setupMockUser(UserType userType) {
    switch (userType) {
      case UserType.loggedOut:
        when(() => firebaseAuth.currentUser).thenReturn(null);
        return null;

      case UserType.anonymous:
        final user = MockUser();
        when(() => user.isAnonymous).thenReturn(true);
        when(() => user.uid).thenReturn(uid);
        when(() => firebaseAuth.currentUser).thenReturn(user);
        return user;
      case UserType.loggedIn:
        final user = MockUser();
        when(() => user.isAnonymous).thenReturn(false);
        when(() => user.uid).thenReturn(uid);
        when(() => firebaseAuth.currentUser).thenReturn(user);
        return user;
    }
  }

  void setupAnimalMocks(List<Animal> animals) {
    when(() => localPool.itemFromJson(any())).thenAnswer(
      (invocation) => Animal.fromMap(invocation.positionalArguments.first),
    );
    for (final animal in animals) {
      when(() => localPool.itemToJson(animal)).thenReturn(animal.toMap());
      when(() => localPool.getItemID(animal)).thenAnswer(
        (invocation) => animal.id,
      );
    }
  }

  setUp(() {
    localPool = MockHydratedCubitPool<Animal>();
    firebaseAuth = MockFirebaseAuth();
    firestore = MockFirebaseFirestore();
    userStreamController = StreamController<User?>();
    collectionReference = StubbedCollectionReference();

    setUpLocalPool([bear]);
    setupAnimalMocks([bear, deer]);

    when(() => firestore.collection("$uid/animals"))
        .thenReturn(collectionReference);
    when(() => firebaseAuth.userChanges()).thenAnswer(
      (_) => userStreamController.stream,
    );

    collectionReference.doc(deer.id).set(deer.toMap());
  });

  HybridPool<Animal> build() => HybridPool<Animal>(
        localPool: localPool,
        auth: firebaseAuth,
        firestore: firestore,
        collectionPath: (user) => "${user.uid}/animals",
        updateDelayDuration: delayDuration,
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
      setupMockUser(UserType.anonymous);

      final pool = build();
      await pumpEventQueue();

      expect(pool.getByID(bear.id), bear);
    },
  );

  test(
    "Given there is a non-anon user signed in, when constructed, expose data from Firebase.",
    () async {
      setUpLocalPool([]);

      setupMockUser(UserType.loggedIn);

      final pool = build();
      await pumpEventQueue();

      expect(pool.getByID(deer.id), deer);
      expect(pool.getByID(bear.id), null);
    },
  );

  test(
    "Given there is no user logged in, when a non-anon user signs in, then copy HydratedCubit data to Firebase and delete it from HydratedCubit.",
    () async {
      when(() => firebaseAuth.currentUser).thenReturn(null);

      final pool = build();
      await pumpEventQueue();

      expect(pool.getByID(bear.id), bear);

      final user = setupMockUser(UserType.loggedIn);
      userStreamController.add(user);

      await pumpEventQueue();

      expect(pool.getByID(bear.id), bear);
      expect(pool.getByID(deer.id), deer);

      verify(() => localPool.delete(bear));
    },
  );

  test(
    "Given there is an anonymous user logged in, when a non-anon user signs in, then copy HydratedCubit data to Firebase and delete it from HydratedCubit.",
    () async {
      setupMockUser(UserType.anonymous);

      final pool = build();
      await pumpEventQueue();

      expect(pool.getByID(bear.id), bear);

      final user = setupMockUser(UserType.loggedIn);
      userStreamController.add(user);

      await pumpEventQueue();

      expect(pool.getByID(bear.id), bear);
      expect(pool.getByID(deer.id), deer);

      verify(() => localPool.delete(bear));
    },
  );

  test(
    "Given there is a non-anon user signed in, when the user signs out, then switch to exposing HydratedCubit data.",
    () async {
      setUpLocalPool([]);
      setupMockUser(UserType.loggedIn);

      final pool = build();
      await pumpEventQueue();

      expect(pool.getByID(deer.id), deer);
      expect(pool.getByID(bear.id), null);

      setUpLocalPool([bear]);

      userStreamController.add(null);

      await pumpEventQueue();

      expect(pool.getByID(bear.id), bear);
      expect(pool.getByID(deer.id), null);
    },
  );

  test(
    "Given there is no user logged in, when a non-anon user signs in and Firebase data copy fails, do not delete HydratedCubit data.",
    () async {
      when(() => firebaseAuth.currentUser).thenReturn(null);

      final pool = build();
      await pumpEventQueue();

      expect(pool.getByID(bear.id), bear);

      final user = setupMockUser(UserType.loggedIn);

      collectionReference = MockCollectionReference();

      when(() => collectionReference.doc(any())).thenThrow(
        Exception("Some error when getting a doc from the collection."),
      );

      final snapshot = MockQuerySnapshot();

      when(() => snapshot.docs).thenAnswer((_) => []);
      when((() => collectionReference.get())).thenAnswer((_) async => snapshot);

      when(() => firestore.collection("$uid/animals"))
          .thenReturn(collectionReference);

      userStreamController.add(user);

      await pumpEventQueue();

      verifyNever(() => localPool.delete(bear));
    },
  );

  test(
    "Given there is no user logged in, when upsert is called, immediately call notifyListeners() and update local storage.",
    () async {
      setupMockUser(UserType.loggedOut);

      const wolf = Animal(id: "2", name: "Wolf", count: 2);
      setupAnimalMocks([wolf]);

      final pool = build();
      expect(pool.getByID(wolf.id), null);

      bool notifyCalled = false;
      pool.addListener(() {
        notifyCalled = true;
      });

      pool.upsert(wolf);

      verify(() => localPool.upsert(wolf));
      expect(pool.getByID(wolf.id), wolf);
      expect(notifyCalled, true);
    },
  );

  test(
    "Given there is an anonymous user logged in, when upsert is called, immediately call notifyListeners() and update local storage.",
    () async {
      setupMockUser(UserType.anonymous);

      const wolf = Animal(id: "2", name: "Wolf", count: 2);
      setupAnimalMocks([wolf]);

      final pool = build();
      expect(pool.getByID(wolf.id), null);

      bool notifyCalled = false;
      pool.addListener(() {
        notifyCalled = true;
      });

      pool.upsert(wolf);
      expect(pool.getByID(wolf.id), wolf);
      verify(() => localPool.upsert(wolf));
      expect(notifyCalled, true);
    },
  );

  test(
    "Given there is a non-anon user logged in, when the data changes, immediately call notifyListeners() and after a delay update Firestore.",
    () async {
      setupMockUser(UserType.loggedIn);

      const wolf = Animal(id: "2", name: "Wolf", count: 2);
      setupAnimalMocks([wolf]);

      final pool = build();
      expect(pool.getByID(wolf.id), null);

      bool notifyCalled = false;
      pool.addListener(() {
        notifyCalled = true;
      });

      pool.upsert(wolf);
      expect(notifyCalled, true);
      expect(pool.getByID(wolf.id), wolf);

      var data = await collectionReference.doc(wolf.id).get();
      expect(data.data(), <String, dynamic>{});

      await Future.delayed(delayDuration + const Duration(milliseconds: 100));

      data = await collectionReference.doc(wolf.id).get();
      expect(data.data(), wolf.toMap());

      verifyNever(() => localPool.upsert(wolf));
    },
  );

  // TODO: Unit tests for deleting

  // TODO: Unit tests for refresh
}
