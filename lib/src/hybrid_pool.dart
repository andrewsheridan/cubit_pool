import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cubit_pool/src/hydrated_cubit_pool.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import 'hybrid_storage_loading_state.dart';
import 'item_updated_event.dart';

abstract class HybridPool<T> extends ChangeNotifier {
  @protected
  final HydratedCubitPool<T> localPool;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final String Function(User user) collectionPath;
  @protected
  late final Logger logger = Logger("HybridPool<${T.toString()}>");
  final Duration _updateDelayDuration;
  late final StreamSubscription<User?> _userSubscription;

  final StreamController<T> _itemAddedController = StreamController.broadcast();
  final StreamController<ItemUpdatedEvent<T>> _itemUpdatedController =
      StreamController.broadcast();
  final StreamController<T> _itemDeletedController =
      StreamController.broadcast();
  final StreamController<HybridStorageLoadingState> _loadingStateController =
      StreamController.broadcast();

  Stream<T> get itemAddedStream => _itemAddedController.stream;
  Stream<ItemUpdatedEvent<T>> get itemUpdatedStream =>
      _itemUpdatedController.stream;
  Stream<T> get itemDeletedStream => _itemDeletedController.stream;
  Stream<HybridStorageLoadingState> get loadingStateStream =>
      _loadingStateController.stream;

  final Map<String, T> _state = <String, T>{};
  final Map<String, T> _updates = <String, T>{};
  HybridStorageLoadingState _loadingState = HybridStorageLoadingState.notLoaded;
  HybridStorageLoadingState get loadingState => _loadingState;

  String? _syncedUserID;
  String? get syncedUserID => _syncedUserID;

  Timer? _timer;

  T? getByID(String id) => _state[id];

  UnmodifiableMapView<String, T> get state => UnmodifiableMapView(_state);

  HybridPool({
    required this.localPool,
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required this.collectionPath,
    required Duration updateDelayDuration,
  }) : _auth = auth,
       _firestore = firestore,
       _updateDelayDuration = updateDelayDuration {
    logger.finer(
      "CurrentUser when constructed: ${auth.currentUser == null
          ? "null"
          : auth.currentUser!.isAnonymous
          ? "Anonymous"
          : "Logged In"}",
    );
    final userStream = _auth.userChanges();
    _userSubscription = userStream.listen(syncData);
    syncData(_auth.currentUser);
  }

  @override
  void dispose() {
    _userSubscription.cancel();
    super.dispose();
  }

  Future<void> waitForLoad() async {
    if (_loadingState == HybridStorageLoadingState.loaded) return;

    await loadingStateStream.firstWhere(
      (s) => s == HybridStorageLoadingState.loaded,
    );
  }

  bool _shouldUseLocalPool(User? user) {
    return user == null || user.isAnonymous;
  }

  @protected
  @mustCallSuper
  Future<void> syncData(User? user, {bool isRefresh = false}) async {
    logger.info("Getting data for user ${user?.uid ?? "null"}");

    _loadingState = isRefresh
        ? HybridStorageLoadingState.refreshing
        : HybridStorageLoadingState.loading;
    _loadingStateController.add(_loadingState);
    notifyListeners();

    try {
      final useLocalPool = _shouldUseLocalPool(user);

      if (useLocalPool) {
        final data = localPool.state;
        if (data != _state) {
          _state.clear();
          _state.addAll(localPool.state);
        }
      } else {
        final path = collectionPath(user!);
        final collection = _firestore.collection(path);

        final localData = localPool.state;

        if (localData.isNotEmpty) {
          try {
            logger.info("Copying local data to cloud.");

            for (final entry in localData.entries) {
              try {
                await _setFirebaseValue(entry.value);
                localPool.delete(entry.value);
              } catch (ex) {
                logger.severe(
                  "Failed to upload local item ${entry.value.toString()}",
                );
              }
            }
            logger.info("Finished copying local data to cloud.");
          } catch (ex) {
            logger.severe("Failed to upload local data.", ex);
          }
        }

        final snapshot = await collection.get();
        final docs = snapshot.docs;
        final data = <String, T>{};

        for (final doc in docs) {
          try {
            final item = localPool.itemFromJson(doc.data());
            final id = localPool.getItemID(item);
            data[id] = item;
          } catch (ex) {
            logger.severe("Failed to parse document data. ${doc.data()}", ex);
          }
        }
        _state.clear();
        _state.addAll(data);
      }
    } catch (ex) {
      logger.severe("Failed to get data.", ex);
    }

    logger.info("Loading complete.");
    _loadingState = HybridStorageLoadingState.loaded;
    _loadingStateController.add(_loadingState);
    _syncedUserID = user == null || user.isAnonymous ? null : user.uid;

    notifyListeners();
  }

  Future<void> _setFirebaseValue(T value) {
    final id = localPool.getItemID(value);
    return _firestore
        .collection(collectionPath(_auth.currentUser!))
        .doc(id)
        .set(localPool.itemToJson(value));
  }

  Future<void> upsert(T value) async {
    final id = localPool.getItemID(value);
    final before = _state[id];

    _state[id] = value;

    if (before != null) {
      _itemUpdatedController.add(ItemUpdatedEvent(before, value));
    } else {
      _itemAddedController.add(value);
    }

    notifyListeners();

    if (_shouldUseLocalPool(_auth.currentUser)) {
      localPool.upsert(value);
    } else {
      _updates[id] = value;
      _timer?.cancel();
      _timer = Timer(_updateDelayDuration, _executeUpdates);
    }
  }

  Future<void> delete(T value) async {
    final id = localPool.getItemID(value);
    _state.remove(id);
    _itemDeletedController.add(value);
    notifyListeners();

    if (_shouldUseLocalPool(_auth.currentUser)) {
      localPool.delete(value);
    } else {
      try {
        return _firestore
            .collection(collectionPath(_auth.currentUser!))
            .doc(id)
            .delete();
      } catch (ex) {
        logger.severe("Failed to remove item from Firebase storage.", ex);
        rethrow;
      }
    }
  }

  Future<void> refresh() {
    return syncData(_auth.currentUser);
  }

  Future<void> _executeUpdates() async {
    final updates = Map.from(_updates);
    final successfulUpdateIDs = <String>{};
    for (final update in updates.entries) {
      try {
        await _setFirebaseValue(update.value);
        successfulUpdateIDs.add(update.key);
      } catch (ex) {
        logger.severe(
          "Failed to update item with id ${update.key} and value ${localPool.itemToJson(update.value)}",
          ex,
        );
      }
    }

    for (final id in successfulUpdateIDs) {
      _updates.remove(id);
    }
  }
}
