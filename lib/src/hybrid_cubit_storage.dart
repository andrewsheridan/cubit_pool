import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cubit_pool/src/hydrated_cubit_with_setter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../cubit_pool.dart';

abstract class HybridCubitStorage<T> extends ChangeNotifier {
  @protected
  final HydratedCubitWithSetter<T> localCubit;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final String Function(User user) docPath;
  final T defaultValue;
  @protected
  late final Logger logger = Logger("HybridPool<${T.toString()}>");
  final Duration _updateDelayDuration;
  late final StreamSubscription<User?> _userSubscription;

  final StreamController<ItemUpdatedEvent<T>> _itemUpdatedController =
      StreamController.broadcast();
  final StreamController<HybridStorageLoadingState> _loadingStateController =
      StreamController.broadcast();

  Stream<ItemUpdatedEvent<T>> get itemUpdatedStream =>
      _itemUpdatedController.stream;

  Stream<HybridStorageLoadingState> get loadingStateStream =>
      _loadingStateController.stream;

  late T _state = defaultValue;
  T get state => _state;
  T? _update;

  HybridStorageLoadingState _loadingState = HybridStorageLoadingState.notLoaded;
  HybridStorageLoadingState get loadingState => _loadingState;

  String? _syncedUserID;
  String? get syncedUserID => _syncedUserID;

  Timer? _timer;

  HybridCubitStorage({
    required this.localCubit,
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required this.docPath,
    required Duration updateDelayDuration,
    required this.defaultValue,
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
        final data = localCubit.state;
        if (data != _state) {
          _state = data;
        }
      } else {
        final path = docPath(user!);
        final doc = _firestore.doc(path);

        final localData = localCubit.state;

        if (localData != defaultValue) {
          try {
            logger.info("Copying local data to cloud.");

            try {
              await _setFirebaseValue(localData);
              localCubit.clear();
            } catch (ex) {
              logger.severe(
                "Failed to upload local item ${localData.toString()}",
              );
            }

            logger.info("Finished copying local data to cloud.");
          } catch (ex) {
            logger.severe("Failed to upload local data.", ex);
          }
        }

        final snapshot = await doc.get();

        final data = snapshot.data();
        _state = data == null
            ? defaultValue
            : localCubit.fromJson(data) ?? defaultValue;
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

  Future<void> _setFirebaseValue(T value) async {
    final json = localCubit.toJson(value);
    if (json == null) return;
    return _firestore.doc(docPath(_auth.currentUser!)).set(json);
  }

  Future<void> setValue(T value) async {
    final before = _state;
    _state = value;

    _itemUpdatedController.add(ItemUpdatedEvent(before, value));

    notifyListeners();

    if (_shouldUseLocalPool(_auth.currentUser)) {
      localCubit.setState(value);
    } else {
      _update = value;
      _timer?.cancel();
      _timer = Timer(_updateDelayDuration, _executeUpdates);
    }
  }

  Future<void> refresh() {
    return syncData(_auth.currentUser);
  }

  Future<void> _executeUpdates() async {
    final update = _update;
    if (update == null) return;
    try {
      await _setFirebaseValue(update);
    } catch (ex) {
      logger.severe("Failed to update item ${update.toString()}", ex);
    }
  }
}
