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

const String animalsProperty = "animals";

class AnimalStorage extends HybridCubitStorage<AnimalListState> {
  AnimalStorage({
    required super.localCubit,
    required super.auth,
    required super.firestore,
    required super.updateDelayDuration,
  }) : super(
         defaultValue: AnimalListState(),
         firebaseProperty: animalsProperty,
         docPath: (user) => "users/${user.uid}",
       );
}

void main() {
  late MockHydratedCubitWithSetter<AnimalListState> animalCubit;
  late MockFirebaseAuth firebaseAuth;
  late MockFirebaseFirestore firestore;
  late StreamController<User?> userStreamController;
  late DocumentReference<Map<String, dynamic>> docReference;

  const uid = "UserID";

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
      getData: () => {animalsProperty: currentFirebaseValue?.toJson()},
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
    when(() => firestore.doc(any())).thenReturn(docReference);
    when(() => docReference.update(any())).thenAnswer((invocation) async {
      final argument = invocation.positionalArguments.first;
      currentFirebaseValue = argument == null
          ? null
          : AnimalListState.fromJson(argument[animalsProperty]);
    });
    when(
      () => firebaseAuth.userChanges(),
    ).thenAnswer((_) => userStreamController.stream);
  });

  AnimalStorage build() => AnimalStorage(
    localCubit: animalCubit,
    auth: firebaseAuth,
    firestore: firestore,
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

  test(
    "Given there is no user logged in, when a non-anon user signs in, then copy HydratedCubit data to Firebase and delete it from HydratedCubit.",
    () async {
      setupMockUser(UserType.loggedOut);
      final localState = setUpLocalPool([deer, bear], bear.id);

      final pool = build();
      await pumpEventQueue();

      expect(pool.state, localState);

      final user = setupMockUser(UserType.loggedIn);
      userStreamController.add(user);

      await pumpEventQueue();

      expect(pool.state, localState);
      expect(currentFirebaseValue, localState);
      verify(() => docReference.update({animalsProperty: localState.toJson()}));
      verify(() => animalCubit.setState(AnimalListState()));
      verify(() => animalCubit.clear());
    },
  );

  test(
    "Given there is an anonymous user logged in, when a non-anon user signs in, then copy HydratedCubit data to Firebase and delete it from HydratedCubit.",
    () async {
      setupMockUser(UserType.anonymous);
      final localState = setUpLocalPool([deer, bear], bear.id);

      final pool = build();
      await pumpEventQueue();

      expect(pool.state, localState);

      final user = setupMockUser(UserType.loggedIn);
      userStreamController.add(user);

      await pumpEventQueue();

      expect(pool.state, localState);
      expect(currentFirebaseValue, localState);
      verify(() => docReference.update({animalsProperty: localState.toJson()}));
      verify(() => animalCubit.setState(AnimalListState()));
      verify(() => animalCubit.clear());
    },
  );

  test(
    "Given there is a non-anon user signed in, when the user signs out, then switch to exposing HydratedCubit data.",
    () async {
      setUpLocalPool([], null);
      final firebaseState = setUpFirebase([bear, deer], deer.id);
      setupMockUser(UserType.loggedIn);

      final pool = build();
      await pumpEventQueue();

      expect(pool.state, firebaseState);

      final localState = setUpLocalPool([bear], bear.id);

      userStreamController.add(null);

      await pumpEventQueue();

      expect(pool.state, localState);
    },
  );

  test(
    "Given there is no user logged in, when a non-anon user signs in and Firebase data copy fails, do not delete HydratedCubit data.",
    () async {
      when(() => firebaseAuth.currentUser).thenReturn(null);
      final localData = setUpLocalPool([bear, deer], null);

      final pool = build();
      await pumpEventQueue();

      expect(pool.state, localData);

      docReference = MockDocumentReference();

      when(() => docReference.get(any())).thenThrow(
        Exception("Some error when getting a doc from the collection."),
      );

      when(() => firestore.doc("users/$uid")).thenReturn(docReference);

      final user = setupMockUser(UserType.loggedIn);
      userStreamController.add(user);

      await pumpEventQueue();

      verifyNever(() => animalCubit.clear());
      verifyNever(() => animalCubit.setState(any()));
    },
  );

  test(
    "Given there is no user logged in, when setState is called, immediately call notifyListeners() and update local storage.",
    () async {
      setupMockUser(UserType.loggedOut);

      const wolf = Animal(id: "2", name: "Wolf", count: 2);
      final localState = setUpLocalPool([wolf], wolf.id);

      final pool = build();
      expect(pool.state, localState);

      bool notifyCalled = false;
      pool.addListener(() {
        notifyCalled = true;
      });

      final updatedState = AnimalListState(
        animals: [deer, wolf],
        currentAnimalID: deer.id,
      );
      pool.setState(updatedState);
      verify(() => animalCubit.setState(updatedState));
      verifyNever(() => docReference.update(any()));
      expect(pool.state, updatedState);
      expect(notifyCalled, true);
    },
  );

  test(
    "Given there is an anonymous user logged in, when setState is called, immediately call notifyListeners() and update local storage.",
    () async {
      setupMockUser(UserType.anonymous);

      const wolf = Animal(id: "2", name: "Wolf", count: 2);
      final localState = setUpLocalPool([wolf], wolf.id);

      final pool = build();
      expect(pool.state, localState);

      bool notifyCalled = false;
      pool.addListener(() {
        notifyCalled = true;
      });

      final updatedState = AnimalListState(
        animals: [deer, wolf],
        currentAnimalID: deer.id,
      );
      pool.setState(updatedState);
      verify(() => animalCubit.setState(updatedState));
      verifyNever(() => docReference.update(any()));
      expect(pool.state, updatedState);
      expect(notifyCalled, true);
    },
  );

  test(
    "Given there is a non-anon user logged in, when the data changes, immediately call notifyListeners() and after a delay update Firestore.",
    () async {
      setupMockUser(UserType.loggedIn);

      const wolf = Animal(id: "2", name: "Wolf", count: 2);
      final firebaseState = setUpFirebase([wolf, deer], wolf.id);
      setUpLocalPool([], null);

      final pool = build();
      await pool.waitForLoad();

      expect(pool.state, firebaseState);

      bool notifyCalled = false;
      pool.addListener(() {
        notifyCalled = true;
      });

      final updatedState = AnimalListState(
        animals: [bear, deer, wolf],
        currentAnimalID: bear.id,
      );
      pool.setState(updatedState);
      expect(notifyCalled, true);
      expect(pool.state, updatedState);

      var data = await docReference.get();
      expect(data.data()![animalsProperty], firebaseState.toJson());

      await Future.delayed(delayDuration + const Duration(milliseconds: 100));

      data = await docReference.get();
      expect(data.data()![animalsProperty], updatedState.toJson());

      verifyNever(() => animalCubit.setState(any()));
    },
  );

  test(
    "Given the user is not logged in, when refresh is called, the latest state from local storage is exposed.",
    () async {
      setupMockUser(UserType.loggedOut);
      final initialLocalState = setUpLocalPool([bear], bear.id);

      final pool = build();

      await pool.waitForLoad();

      expect(pool.state, initialLocalState);

      const sheep = Animal(id: "4", name: "Sheep", count: 100);
      final updatedLocalState = setUpLocalPool([bear, sheep], sheep.id);

      expect(pool.state, initialLocalState);

      await pool.refresh();

      expect(pool.state, updatedLocalState);
    },
  );

  test(
    "Given the user is anonymous, when refresh is called, the latest state from local storage is exposed.",
    () async {
      setupMockUser(UserType.loggedOut);
      final initialLocalState = setUpLocalPool([bear], bear.id);

      final pool = build();

      await pool.waitForLoad();

      expect(pool.state, initialLocalState);

      const sheep = Animal(id: "4", name: "Sheep", count: 100);
      final updatedLocalState = setUpLocalPool([bear, sheep], sheep.id);

      expect(pool.state, initialLocalState);

      await pool.refresh();

      expect(pool.state, updatedLocalState);
    },
  );

  test(
    "Given the user is logged in, when refresh is called, the latest state from Firestore is exposed.",
    () async {
      setupMockUser(UserType.loggedIn);
      setUpLocalPool([], null);
      final initialFirebaseState = setUpFirebase([bear], bear.id);

      final pool = build();

      await pool.waitForLoad();

      expect(pool.state, initialFirebaseState);

      const sheep = Animal(id: "4", name: "Sheep", count: 100);

      final updatedState = AnimalListState(
        animals: [bear, sheep, deer],
        currentAnimalID: sheep.id,
      );

      await docReference.update({animalsProperty: updatedState.toJson()});

      expect(pool.state, initialFirebaseState);

      await pool.refresh();

      expect(pool.state, updatedState);
    },
  );
}
