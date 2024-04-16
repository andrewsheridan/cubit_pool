import 'dart:convert';

import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'cubit_pool.dart';

abstract class HydratedCubitPool<T> extends CubitPool<T> with HydratedMixin {
  HydratedCubitPool({super.initialState = const {}}) {
    hydrate();
  }

  @override
  Map<String, T>? fromJson(Map<String, dynamic> json) {
    final output = <String, T>{};
    for (final key in json.keys) {
      try {
        output[key] = itemFromJson(json[key]);
      } catch (ex) {
        logger.severe(
            "Failed to parse ${jsonEncode(json[key])} from json.", ex);
      }
    }
    return output;
  }

  @override
  Map<String, dynamic>? toJson(Map<String, T> state) {
    final output = <String, dynamic>{};

    for (final key in state.keys) {
      try {
        output[key] = itemToJson(state[key] as T);
      } catch (ex) {
        logger.severe("Failed to parse ${state[key]!.toString()}", ex);
      }
    }
    return output;
  }
}
