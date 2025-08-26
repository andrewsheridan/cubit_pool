// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'animal_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AnimalListState {

 List<Animal> get animals; String? get currentAnimalID;
/// Create a copy of AnimalListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnimalListStateCopyWith<AnimalListState> get copyWith => _$AnimalListStateCopyWithImpl<AnimalListState>(this as AnimalListState, _$identity);

  /// Serializes this AnimalListState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnimalListState&&const DeepCollectionEquality().equals(other.animals, animals)&&(identical(other.currentAnimalID, currentAnimalID) || other.currentAnimalID == currentAnimalID));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(animals),currentAnimalID);

@override
String toString() {
  return 'AnimalListState(animals: $animals, currentAnimalID: $currentAnimalID)';
}


}

/// @nodoc
abstract mixin class $AnimalListStateCopyWith<$Res>  {
  factory $AnimalListStateCopyWith(AnimalListState value, $Res Function(AnimalListState) _then) = _$AnimalListStateCopyWithImpl;
@useResult
$Res call({
 List<Animal> animals, String? currentAnimalID
});




}
/// @nodoc
class _$AnimalListStateCopyWithImpl<$Res>
    implements $AnimalListStateCopyWith<$Res> {
  _$AnimalListStateCopyWithImpl(this._self, this._then);

  final AnimalListState _self;
  final $Res Function(AnimalListState) _then;

/// Create a copy of AnimalListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? animals = null,Object? currentAnimalID = freezed,}) {
  return _then(_self.copyWith(
animals: null == animals ? _self.animals : animals // ignore: cast_nullable_to_non_nullable
as List<Animal>,currentAnimalID: freezed == currentAnimalID ? _self.currentAnimalID : currentAnimalID // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AnimalListState].
extension AnimalListStatePatterns on AnimalListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnimalListState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnimalListState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnimalListState value)  $default,){
final _that = this;
switch (_that) {
case _AnimalListState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnimalListState value)?  $default,){
final _that = this;
switch (_that) {
case _AnimalListState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Animal> animals,  String? currentAnimalID)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnimalListState() when $default != null:
return $default(_that.animals,_that.currentAnimalID);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Animal> animals,  String? currentAnimalID)  $default,) {final _that = this;
switch (_that) {
case _AnimalListState():
return $default(_that.animals,_that.currentAnimalID);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Animal> animals,  String? currentAnimalID)?  $default,) {final _that = this;
switch (_that) {
case _AnimalListState() when $default != null:
return $default(_that.animals,_that.currentAnimalID);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnimalListState implements AnimalListState {
  const _AnimalListState({final  List<Animal> animals = const [], this.currentAnimalID}): _animals = animals;
  factory _AnimalListState.fromJson(Map<String, dynamic> json) => _$AnimalListStateFromJson(json);

 final  List<Animal> _animals;
@override@JsonKey() List<Animal> get animals {
  if (_animals is EqualUnmodifiableListView) return _animals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_animals);
}

@override final  String? currentAnimalID;

/// Create a copy of AnimalListState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnimalListStateCopyWith<_AnimalListState> get copyWith => __$AnimalListStateCopyWithImpl<_AnimalListState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnimalListStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnimalListState&&const DeepCollectionEquality().equals(other._animals, _animals)&&(identical(other.currentAnimalID, currentAnimalID) || other.currentAnimalID == currentAnimalID));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_animals),currentAnimalID);

@override
String toString() {
  return 'AnimalListState(animals: $animals, currentAnimalID: $currentAnimalID)';
}


}

/// @nodoc
abstract mixin class _$AnimalListStateCopyWith<$Res> implements $AnimalListStateCopyWith<$Res> {
  factory _$AnimalListStateCopyWith(_AnimalListState value, $Res Function(_AnimalListState) _then) = __$AnimalListStateCopyWithImpl;
@override @useResult
$Res call({
 List<Animal> animals, String? currentAnimalID
});




}
/// @nodoc
class __$AnimalListStateCopyWithImpl<$Res>
    implements _$AnimalListStateCopyWith<$Res> {
  __$AnimalListStateCopyWithImpl(this._self, this._then);

  final _AnimalListState _self;
  final $Res Function(_AnimalListState) _then;

/// Create a copy of AnimalListState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? animals = null,Object? currentAnimalID = freezed,}) {
  return _then(_AnimalListState(
animals: null == animals ? _self._animals : animals // ignore: cast_nullable_to_non_nullable
as List<Animal>,currentAnimalID: freezed == currentAnimalID ? _self.currentAnimalID : currentAnimalID // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
