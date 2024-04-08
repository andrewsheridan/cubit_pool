import 'dart:convert';

import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'cubit_pool.dart';

class HydratedCubitPool<T> extends CubitPool<T> with HydratedMixin {
  HydratedCubitPool({
    required super.from,
    required super.to,
    required super.getID,
    required super.initialState,
  });

  @override
  Map<String, T>? fromJson(Map<String, dynamic> json) {
    final output = <String, T>{};
    for (final key in json.keys) {
      try {
        output[key] = from(json[key]);
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
        output[key] = to(state[key] as T);
      } catch (ex) {
        logger.severe("Failed to parse ${state[key]!.toString()}", ex);
      }
    }
    return output;
  }
}
