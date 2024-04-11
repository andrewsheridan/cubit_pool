import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:logging/logging.dart';

class CubitPool<T> extends Cubit<Map<String, T>> {
  final Map<String, dynamic> Function(T item) to;
  final T Function(Map<String, dynamic> json) from;
  final String Function(T value) getID;

  final Logger logger = Logger("Pool<${T.runtimeType}>");

  final StreamController<T> _itemAddedController = StreamController.broadcast();
  final StreamController<T> _itemUpdatedController =
      StreamController.broadcast();
  final StreamController<T> _itemDeletedController =
      StreamController.broadcast();

  Stream<T> get itemAddedStream => _itemAddedController.stream;
  Stream<T> get itemUpdatedStream => _itemUpdatedController.stream;
  Stream<T> get itemDeletedStream => _itemDeletedController.stream;

  CubitPool({
    required this.from,
    required this.to,
    required this.getID,
    Map<String, T> initialState = const {},
  }) : super(initialState);

  @mustCallSuper
  void upsert(T thing) {
    final exists = state.containsKey(getID(thing));

    emit({...state, getID(thing): thing});
    if (exists) {
      _itemUpdatedController.sink.add(thing);
    } else {
      _itemAddedController.sink.add(thing);
    }
  }

  @mustCallSuper
  void delete(T item) {
    final id = getID(item);
    if (!state.containsKey(id)) return;

    emit(Map.fromEntries(state.entries.where((e) => e.key != id)));

    _itemDeletedController.sink.add(item);
  }
}
