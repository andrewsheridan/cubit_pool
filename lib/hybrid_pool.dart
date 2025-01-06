import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cubit_pool/hydrated_cubit_pool.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class HybridPool<T> extends ChangeNotifier {
  final HydratedCubitPool<T> _localPool;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final Logger _logger = Logger("HybridPool");
  late final StreamSubscription<User?> _userSubscription;
  User? _user;
  final bool _useLocalPool = true;

  HybridPool({
    required HydratedCubitPool<T> localPool,
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _localPool = localPool,
        _auth = auth,
        _firestore = firestore {
    final userStream = _auth.userChanges();
    _userSubscription = userStream.listen(_handleUserChanged);
    _handleUserChanged(_auth.currentUser);
  }

  @override
  void dispose() {
    _userSubscription.cancel();
    super.dispose();
  }

  bool _shouldUseLocalPool(User? user) {
    return user == null || user.isAnonymous;
  }

  void _handleUserChanged(User? user) {
    final useLocalPool = _shouldUseLocalPool(user);

    if (useLocalPool) {
      final data = _localPool.state;
      if (data != _map) {
        _map = data;
        notifyListeners();
      }
    } else {
      // TODO
    }

    _user = user;
  }

  Map<String, T> _map = {};

  T? getByID(String id) => _map[id];
}
