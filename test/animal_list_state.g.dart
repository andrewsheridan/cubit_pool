// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: non_constant_identifier_names, unnecessary_null_in_if_null_operators

part of 'animal_list_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AnimalListState _$AnimalListStateFromJson(Map<String, dynamic> json) =>
    _AnimalListState(
      animals:
          (json['animals'] as List<dynamic>?)
              ?.map((e) => Animal.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      currentAnimalID: json['currentAnimalID'] as String?,
    );

Map<String, dynamic> _$AnimalListStateToJson(_AnimalListState instance) =>
    <String, dynamic>{
      'animals': instance.animals.map((e) => e.toJson()).toList(),
      'currentAnimalID': ?instance.currentAnimalID,
    };
