import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cubit_pool/hydrated_cubit_pool.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class HybridPool<T> extends ChangeNotifier {
  final HydratedCubitPool<T> _localPool;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final String Function(User user) collectionPath;
  final Logger _logger = Logger("HybridPool");
  final Duration _updateDelayDuration;
  late final StreamSubscription<User?> _userSubscription;

  Map<String, T> _state = {};
  final Map<String, T> _updates = {};

  Timer? _timer;

  T? getByID(String id) => _state[id];

  UnmodifiableMapView<String, T> get state => UnmodifiableMapView(_state);

  HybridPool({
    required HydratedCubitPool<T> localPool,
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required this.collectionPath,
    required Duration updateDelayDuration,
  })  : _localPool = localPool,
        _auth = auth,
        _firestore = firestore,
        _updateDelayDuration = updateDelayDuration {
    final userStream = _auth.userChanges();
    _userSubscription = userStream.listen(_getData);
    _getData(_auth.currentUser);
  }

  @override
  void dispose() {
    _userSubscription.cancel();
    super.dispose();
  }

  bool _shouldUseLocalPool(User? user) {
    return user == null || user.isAnonymous;
  }

  Future<void> _getData(User? user) async {
    final useLocalPool = _shouldUseLocalPool(user);

    if (useLocalPool) {
      final data = _localPool.state;
      if (data != _state) {
        _state = data;
        notifyListeners();
      }
    } else {
      final collection = _firestore.collection(collectionPath(user!));

      final localData = _localPool.state;
      for (final entry in localData.entries) {
        try {
          await _setFirebaseValue(entry.value);
          _localPool.delete(entry.value);
        } catch (ex) {
          _logger.severe(
            "Failed to upload local item ${entry.value.toString()}",
          );
        }
      }

      final snapshot = await collection.get();
      final docs = snapshot.docs;
      final data = <String, T>{};

      for (final doc in docs) {
        final item = _localPool.itemFromJson(doc.data());
        final id = _localPool.getItemID(item);
        data[id] = item;
      }
      _state = data;
      notifyListeners();
    }
  }

  Future<void> _setFirebaseValue(T value) {
    final id = _localPool.getItemID(value);
    return _firestore
        .collection(collectionPath(_auth.currentUser!))
        .doc(id)
        .set(_localPool.itemToJson(value));
  }

  Future<void> upsert(T value) async {
    final id = _localPool.getItemID(value);
    _state[id] = value;

    notifyListeners();
    if (_shouldUseLocalPool(_auth.currentUser)) {
      _localPool.upsert(value);
    } else {
      _updates[id] = value;
      _timer?.cancel();
      _timer = Timer(_updateDelayDuration, _executeUpdates);
    }
  }

  Future<void> delete(T value) async {
    final id = _localPool.getItemID(value);
    _state.remove(id);

    if (_shouldUseLocalPool(_auth.currentUser)) {
      _localPool.delete(value);
    } else {
      try {
        return _firestore
            .collection(collectionPath(_auth.currentUser!))
            .doc(id)
            .delete();
      } catch (ex) {
        _logger.severe(
          "Failed to remove item from Firebase storage.",
          ex,
        );
        rethrow;
      }
    }
  }

  Future<void> refresh() {
    return _getData(_auth.currentUser);
  }

  Future<void> _executeUpdates() async {
    final updates = Map.from(_updates);
    final successfulUpdateIDs = <String>{};
    for (final update in updates.entries) {
      try {
        await _setFirebaseValue(update.value);
        successfulUpdateIDs.add(update.key);
      } catch (ex) {
        _logger.severe(
          "Failed to update item with id ${update.key} and value ${_localPool.itemToJson(update.value)}",
          ex,
        );
      }
    }

    for (final id in successfulUpdateIDs) {
      _updates.remove(id);
    }
  }
}
