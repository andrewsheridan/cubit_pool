// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'animal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Animal {

 String get id; String get name; int get count;
/// Create a copy of Animal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnimalCopyWith<Animal> get copyWith => _$AnimalCopyWithImpl<Animal>(this as Animal, _$identity);

  /// Serializes this Animal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Animal&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,count);

@override
String toString() {
  return 'Animal(id: $id, name: $name, count: $count)';
}


}

/// @nodoc
abstract mixin class $AnimalCopyWith<$Res>  {
  factory $AnimalCopyWith(Animal value, $Res Function(Animal) _then) = _$AnimalCopyWithImpl;
@useResult
$Res call({
 String id, String name, int count
});




}
/// @nodoc
class _$AnimalCopyWithImpl<$Res>
    implements $AnimalCopyWith<$Res> {
  _$AnimalCopyWithImpl(this._self, this._then);

  final Animal _self;
  final $Res Function(Animal) _then;

/// Create a copy of Animal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? count = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Animal].
extension AnimalPatterns on Animal {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Animal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Animal() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Animal value)  $default,){
final _that = this;
switch (_that) {
case _Animal():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Animal value)?  $default,){
final _that = this;
switch (_that) {
case _Animal() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Animal() when $default != null:
return $default(_that.id,_that.name,_that.count);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  int count)  $default,) {final _that = this;
switch (_that) {
case _Animal():
return $default(_that.id,_that.name,_that.count);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  int count)?  $default,) {final _that = this;
switch (_that) {
case _Animal() when $default != null:
return $default(_that.id,_that.name,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Animal implements Animal {
  const _Animal({required this.id, required this.name, required this.count});
  factory _Animal.fromJson(Map<String, dynamic> json) => _$AnimalFromJson(json);

@override final  String id;
@override final  String name;
@override final  int count;

/// Create a copy of Animal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnimalCopyWith<_Animal> get copyWith => __$AnimalCopyWithImpl<_Animal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnimalToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Animal&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,count);

@override
String toString() {
  return 'Animal(id: $id, name: $name, count: $count)';
}


}

/// @nodoc
abstract mixin class _$AnimalCopyWith<$Res> implements $AnimalCopyWith<$Res> {
  factory _$AnimalCopyWith(_Animal value, $Res Function(_Animal) _then) = __$AnimalCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, int count
});




}
/// @nodoc
class __$AnimalCopyWithImpl<$Res>
    implements _$AnimalCopyWith<$Res> {
  __$AnimalCopyWithImpl(this._self, this._then);

  final _Animal _self;
  final $Res Function(_Animal) _then;

/// Create a copy of Animal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? count = null,}) {
  return _then(_Animal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
