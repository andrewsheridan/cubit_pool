// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: non_constant_identifier_names, unnecessary_null_in_if_null_operators

part of 'animal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Animal _$AnimalFromJson(Map<String, dynamic> json) => _Animal(
  id: json['id'] as String,
  name: json['name'] as String,
  count: (json['count'] as num).toInt(),
);

Map<String, dynamic> _$AnimalToJson(_Animal instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'count': instance.count,
};
