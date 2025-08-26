import 'package:freezed_annotation/freezed_annotation.dart';

import 'animal.dart';

part 'animal_list_state.freezed.dart';
part 'animal_list_state.g.dart';

@freezed
abstract class AnimalListState with _$AnimalListState {
  const factory AnimalListState({
    @Default([]) List<Animal> animals,
    String? currentAnimalID,
  }) = _AnimalListState;

  factory AnimalListState.fromJson(Map<String, dynamic> json) =>
      _$AnimalListStateFromJson(json);
}
