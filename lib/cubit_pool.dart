import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:logging/logging.dart';

abstract class CubitPool<T> extends Cubit<Map<String, T>> {
  Map<String, dynamic> itemToJson(T item);
  T itemFromJson(Map<String, dynamic> json);
  String getItemID(T value);

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
    Map<String, T> initialState = const {},
  }) : super(initialState);

  @mustCallSuper
  void upsert(T thing) {
    final exists = state.containsKey(getItemID(thing));

    emit({...state, getItemID(thing): thing});
    if (exists) {
      _itemUpdatedController.sink.add(thing);
    } else {
      _itemAddedController.sink.add(thing);
    }
  }

  @mustCallSuper
  void delete(T item) {
    final id = getItemID(item);
    if (!state.containsKey(id)) return;

    emit(Map.fromEntries(state.entries.where((e) => e.key != id)));

    _itemDeletedController.sink.add(item);
  }
}
