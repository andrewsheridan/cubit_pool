import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cubit_pool/src/hybrid_cubit_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:mocktail/mocktail.dart';

import 'animal.dart';
import 'animal_list_state.dart';
import 'mocks/mock_document_reference.dart';
import 'mocks/mock_firebase_auth.dart';
import 'mocks/mock_firebase_firestore.dart';
import 'mocks/mock_hydrated_cubit_with_setter.dart';
import 'mocks/mock_query_snapshot.dart';
import 'mocks/mock_user.dart';

enum UserType { loggedOut, anonymous, loggedIn }

class AnimalStorage extends HybridCubitStorage<AnimalListState> {
  AnimalStorage({
    required super.localCubit,
    required super.auth,
    required super.firestore,
    required super.docPath,
    required super.updateDelayDuration,
  }) : super(defaultValue: AnimalListState());
}

void main() {
  late MockHydratedCubitWithSetter<AnimalListState> animalCubit;
  late MockFirebaseAuth firebaseAuth;
  late MockFirebaseFirestore firestore;
  late StreamController<User?> userStreamController;
  late DocumentReference<Map<String, dynamic>> docReference;

  const uid = "User ID";

  const delayDuration = Duration(milliseconds: 250);

  const bear = Animal(id: "0", name: "Bear", count: 1);
  const deer = Animal(id: "1", name: "Deer", count: 3);

  AnimalListState? currentFirebaseValue;

  AnimalListState setUpLocalPool(
    List<Animal> animals,
    String? currentAnimalID,
  ) {
    final state = AnimalListState(
      animals: animals,
      currentAnimalID: currentAnimalID,
    );
    when(() => animalCubit.state).thenReturn(state);

    return state;
  }

  AnimalListState setUpFirebase(List<Animal> animals, String? currentAnimalID) {
    final state = AnimalListState(
      animals: animals,
      currentAnimalID: currentAnimalID,
    );
    currentFirebaseValue = state;
    final snapshot = MockQueryDocumentSnapshot(
      getData: () => currentFirebaseValue?.toJson(),
    );

    when(() => docReference.get()).thenAnswer((invocation) async => snapshot);

    return state;
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

  setUpAll(() {
    Logger.root.onRecord.listen((record) {
      final logNoStackTrace =
          "[${record.loggerName}] ${record.level.name} - ${record.message}${(record.error == null ? "" : " - ${record.error}")}";
      final log =
          "$logNoStackTrace${(record.stackTrace == null ? "" : "\n${record.stackTrace}\n\n")}";
      debugPrint(log);
    });
  });

  setUp(() {
    animalCubit = MockHydratedCubitWithSetter<AnimalListState>();
    firebaseAuth = MockFirebaseAuth();
    firestore = MockFirebaseFirestore();
    userStreamController = StreamController<User?>();
    docReference = MockDocumentReference();

    registerFallbackValue(AnimalListState());

    when(() => animalCubit.fromJson(any())).thenAnswer((invocation) {
      final argument = invocation.positionalArguments.first;
      return argument == null ? null : AnimalListState.fromJson(argument);
    });
    when(() => animalCubit.toJson(any())).thenAnswer((invocation) {
      return (invocation.positionalArguments.first as AnimalListState?)
          ?.toJson();
    });
    when(() => firestore.doc("$uid/animals")).thenReturn(docReference);
    when(() => docReference.set(any())).thenAnswer((invocation) async {
      final argument = invocation.positionalArguments.first;
      currentFirebaseValue = argument == null
          ? null
          : AnimalListState.fromJson(argument);
    });
    when(
      () => firebaseAuth.userChanges(),
    ).thenAnswer((_) => userStreamController.stream);
  });

  AnimalStorage build() => AnimalStorage(
    localCubit: animalCubit,
    auth: firebaseAuth,
    firestore: firestore,
    docPath: (user) => "${user.uid}/animals",
    updateDelayDuration: delayDuration,
  );

  test(
    "Given there is no user logged in, when constructed, expose data from HydratedCubit.",
    () async {
      when(() => firebaseAuth.currentUser).thenReturn(null);
      final cubitState = setUpLocalPool([bear, deer], bear.id);
      final pool = build();
      await pumpEventQueue();

      expect(pool.state, cubitState);
    },
  );

  test(
    "Given there is an anonymous user logged in, when constructed, expose data from HydratedCubit.",
    () async {
      setupMockUser(UserType.anonymous);

      final cubitState = setUpLocalPool([bear, deer], deer.id);
      final pool = build();
      await pumpEventQueue();

      expect(pool.state, cubitState);
    },
  );

  test(
    "Given there is a non-anon user signed in, when constructed, expose data from Firebase.",
    () async {
      // ignore: unused_local_variable
      final cubitState = setUpLocalPool([], null);
      final firebaseState = setUpFirebase([bear, deer], deer.id);

      setupMockUser(UserType.loggedIn);

      final pool = build();
      await pumpEventQueue();

      expect(pool.state, firebaseState);
    },
  );

  // test(
  //   "Given there is no user logged in, when a non-anon user signs in, then copy HydratedCubit data to Firebase and delete it from HydratedCubit.",
  //   () async {
  //     when(() => firebaseAuth.currentUser).thenReturn(null);

  //     final pool = build();
  //     await pumpEventQueue();

  //     expect(pool.getByID(bear.id), bear);

  //     final user = setupMockUser(UserType.loggedIn);
  //     userStreamController.add(user);

  //     await pumpEventQueue();

  //     expect(pool.getByID(bear.id), bear);
  //     expect(pool.getByID(deer.id), deer);

  //     verify(() => animalCubit.delete(bear));
  //   },
  // );

  // test(
  //   "Given there is an anonymous user logged in, when a non-anon user signs in, then copy HydratedCubit data to Firebase and delete it from HydratedCubit.",
  //   () async {
  //     setupMockUser(UserType.anonymous);

  //     final pool = build();
  //     await pumpEventQueue();

  //     expect(pool.getByID(bear.id), bear);

  //     final user = setupMockUser(UserType.loggedIn);
  //     userStreamController.add(user);

  //     await pumpEventQueue();

  //     expect(pool.getByID(bear.id), bear);
  //     expect(pool.getByID(deer.id), deer);

  //     verify(() => animalCubit.delete(bear));
  //   },
  // );

  // test(
  //   "Given there is a non-anon user signed in, when the user signs out, then switch to exposing HydratedCubit data.",
  //   () async {
  //     setUpLocalPool([]);
  //     setupMockUser(UserType.loggedIn);

  //     final pool = build();
  //     await pumpEventQueue();

  //     expect(pool.getByID(deer.id), deer);
  //     expect(pool.getByID(bear.id), null);

  //     setUpLocalPool([bear]);

  //     userStreamController.add(null);

  //     await pumpEventQueue();

  //     expect(pool.getByID(bear.id), bear);
  //     expect(pool.getByID(deer.id), null);
  //   },
  // );

  // test(
  //   "Given there is no user logged in, when a non-anon user signs in and Firebase data copy fails, do not delete HydratedCubit data.",
  //   () async {
  //     when(() => firebaseAuth.currentUser).thenReturn(null);

  //     final pool = build();
  //     await pumpEventQueue();

  //     expect(pool.getByID(bear.id), bear);

  //     final user = setupMockUser(UserType.loggedIn);

  //     collectionReference = MockCollectionReference();

  //     when(() => collectionReference.doc(any())).thenThrow(
  //       Exception("Some error when getting a doc from the collection."),
  //     );

  //     final snapshot = MockQuerySnapshot();

  //     when(() => snapshot.docs).thenAnswer((_) => []);
  //     when((() => collectionReference.get())).thenAnswer((_) async => snapshot);

  //     when(
  //       () => firestore.collection("$uid/animals"),
  //     ).thenReturn(collectionReference);

  //     userStreamController.add(user);

  //     await pumpEventQueue();

  //     verifyNever(() => animalCubit.delete(bear));
  //   },
  // );

  // test(
  //   "Given there is no user logged in, when upsert is called, immediately call notifyListeners() and update local storage.",
  //   () async {
  //     setupMockUser(UserType.loggedOut);

  //     const wolf = Animal(id: "2", name: "Wolf", count: 2);
  //     setupAnimalMocks([wolf]);

  //     final pool = build();
  //     expect(pool.getByID(wolf.id), null);

  //     bool notifyCalled = false;
  //     pool.addListener(() {
  //       notifyCalled = true;
  //     });

  //     pool.upsert(wolf);

  //     verify(() => animalCubit.upsert(wolf));
  //     expect(pool.getByID(wolf.id), wolf);
  //     expect(notifyCalled, true);
  //   },
  // );

  // test(
  //   "Given there is an anonymous user logged in, when upsert is called, immediately call notifyListeners() and update local storage.",
  //   () async {
  //     setupMockUser(UserType.anonymous);

  //     const wolf = Animal(id: "2", name: "Wolf", count: 2);
  //     setupAnimalMocks([wolf]);

  //     final pool = build();
  //     expect(pool.getByID(wolf.id), null);

  //     bool notifyCalled = false;
  //     pool.addListener(() {
  //       notifyCalled = true;
  //     });

  //     pool.upsert(wolf);
  //     expect(pool.getByID(wolf.id), wolf);
  //     verify(() => animalCubit.upsert(wolf));
  //     expect(notifyCalled, true);
  //   },
  // );

  // test(
  //   "Given there is a non-anon user logged in, when the data changes, immediately call notifyListeners() and after a delay update Firestore.",
  //   () async {
  //     setupMockUser(UserType.loggedIn);

  //     const wolf = Animal(id: "2", name: "Wolf", count: 2);
  //     setupAnimalMocks([wolf]);

  //     final pool = build();
  //     expect(pool.getByID(wolf.id), null);

  //     bool notifyCalled = false;
  //     pool.addListener(() {
  //       notifyCalled = true;
  //     });

  //     pool.upsert(wolf);
  //     expect(notifyCalled, true);
  //     expect(pool.getByID(wolf.id), wolf);

  //     var data = await collectionReference.doc(wolf.id).get();
  //     expect(data.data(), <String, dynamic>{});

  //     await Future.delayed(delayDuration + const Duration(milliseconds: 100));

  //     data = await collectionReference.doc(wolf.id).get();
  //     expect(data.data(), wolf.toMap());

  //     verifyNever(() => animalCubit.upsert(wolf));
  //   },
  // );

  // test(
  //   "Given a user is logged out, when delete is called, then the item will be immediately deleted from the local storage.",
  //   () async {
  //     setupMockUser(UserType.loggedOut);

  //     final pool = build();

  //     expect(pool.state, isNotEmpty);
  //     expect(pool.getByID(bear.id), bear);

  //     pool.delete(bear);

  //     expect(pool.state, isEmpty);
  //     expect(pool.getByID(bear.id), null);
  //     verify(() => animalCubit.delete(bear));
  //   },
  // );

  // test(
  //   "Given a user is anonymous, when delete is called, then the item will be immediately deleted from the local storage.",
  //   () async {
  //     setupMockUser(UserType.anonymous);

  //     final pool = build();

  //     expect(pool.state, isNotEmpty);
  //     expect(pool.getByID(bear.id), bear);

  //     pool.delete(bear);

  //     expect(pool.state, isEmpty);
  //     expect(pool.getByID(bear.id), null);
  //     verify(() => animalCubit.delete(bear));
  //   },
  // );

  // test(
  //   "Given a user is logged in, when delete is called, then the item will be immediately deleted from Firestore.",
  //   () async {
  //     setupMockUser(UserType.loggedIn);

  //     final pool = build();

  //     await pumpEventQueue();

  //     expect(pool.state, isNotEmpty);
  //     expect(pool.getByID(bear.id), bear);
  //     expect(pool.getByID(deer.id), deer);

  //     final bearDocBefore = await collectionReference.doc(bear.id).get();
  //     expect(bearDocBefore.data(), bear.toMap());

  //     final deerDocBefore = await collectionReference.doc(deer.id).get();
  //     expect(deerDocBefore.data(), deer.toMap());

  //     await pool.delete(deer);
  //     await pool.delete(bear);

  //     expect(pool.state, isEmpty);
  //     expect(pool.getByID(deer.id), null);
  //     expect(pool.getByID(bear.id), null);

  //     final bearDoc = await collectionReference.doc(bear.id).get();
  //     expect(bearDoc.data(), {});

  //     final deerDoc = await collectionReference.doc(deer.id).get();
  //     expect(deerDoc.data(), {});
  //   },
  // );

  // test(
  //   "Given the user is not logged in, when refresh is called, the latest state from local storage is exposed.",
  //   () async {
  //     setupMockUser(UserType.loggedOut);

  //     final pool = build();

  //     const sheep = Animal(id: "4", name: "Sheep", count: 100);
  //     setUpLocalPool([bear, sheep]);

  //     expect(pool.state.length, 1);
  //     expect(pool.getByID(sheep.id), null);

  //     await pool.refresh();

  //     expect(pool.state.length, 2);
  //     expect(pool.getByID(sheep.id), sheep);
  //   },
  // );

  // test(
  //   "Given the user is anonymous, when refresh is called, the latest state from local storage is exposed.",
  //   () async {
  //     setupMockUser(UserType.anonymous);

  //     final pool = build();

  //     const sheep = Animal(id: "4", name: "Sheep", count: 100);
  //     setUpLocalPool([bear, sheep]);

  //     expect(pool.state.length, 1);
  //     expect(pool.getByID(sheep.id), null);

  //     await pool.refresh();

  //     expect(pool.state.length, 2);
  //     expect(pool.getByID(sheep.id), sheep);
  //   },
  // );

  // test(
  //   "Given the user is logged in, when refresh is called, the latest state from Firestore is exposed.",
  //   () async {
  //     setupMockUser(UserType.loggedIn);
  //     setUpLocalPool([]);
  //     const sheep = Animal(id: "4", name: "Sheep", count: 100);
  //     setupAnimalMocks([deer, sheep]);

  //     final pool = build();

  //     await pumpEventQueue();

  //     collectionReference.doc(sheep.id).set(sheep.toMap());

  //     expect(pool.state.length, 1);
  //     expect(pool.getByID(sheep.id), null);

  //     await pool.refresh();

  //     expect(pool.state.length, 2);
  //     expect(pool.getByID(sheep.id), sheep);
  //   },
  // );
}
