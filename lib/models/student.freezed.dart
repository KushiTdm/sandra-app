// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'student.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Student {

 String get id;@JsonKey(name: 'last_name') String get lastName;@JsonKey(name: 'first_name') String get firstName;@JsonKey(name: 'display_name') String get displayName;@JsonKey(name: 'pseudo_code') String get pseudoCode;@JsonKey(name: 'group_label') String? get groupLabel;@JsonKey(name: 'first_language') String? get firstLanguage;@JsonKey(name: 'flsco_level') int? get flscoLevel; String? get notes;@JsonKey(name: 'is_active') bool get isActive;
/// Create a copy of Student
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudentCopyWith<Student> get copyWith => _$StudentCopyWithImpl<Student>(this as Student, _$identity);

  /// Serializes this Student to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Student;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Student&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.lastName, _this.lastName) || other.lastName == _this.lastName)&&(identical(other.firstName, _this.firstName) || other.firstName == _this.firstName)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.pseudoCode, _this.pseudoCode) || other.pseudoCode == _this.pseudoCode)&&(identical(other.groupLabel, _this.groupLabel) || other.groupLabel == _this.groupLabel)&&(identical(other.firstLanguage, _this.firstLanguage) || other.firstLanguage == _this.firstLanguage)&&(identical(other.flscoLevel, _this.flscoLevel) || other.flscoLevel == _this.flscoLevel)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Student;
  return Object.hash(runtimeType,_this.id,_this.lastName,_this.firstName,_this.displayName,_this.pseudoCode,_this.groupLabel,_this.firstLanguage,_this.flscoLevel,_this.notes,_this.isActive);
}

@override
String toString() {
  final _this = this as Student;
  return 'Student(id: ${_this.id}, lastName: ${_this.lastName}, firstName: ${_this.firstName}, displayName: ${_this.displayName}, pseudoCode: ${_this.pseudoCode}, groupLabel: ${_this.groupLabel}, firstLanguage: ${_this.firstLanguage}, flscoLevel: ${_this.flscoLevel}, notes: ${_this.notes}, isActive: ${_this.isActive})';
}


}

/// @nodoc
abstract mixin class $StudentCopyWith<$Res>  {
  factory $StudentCopyWith(Student value, $Res Function(Student) _then) = _$StudentCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'last_name') String lastName,@JsonKey(name: 'first_name') String firstName,@JsonKey(name: 'display_name') String displayName,@JsonKey(name: 'pseudo_code') String pseudoCode,@JsonKey(name: 'group_label') String? groupLabel,@JsonKey(name: 'first_language') String? firstLanguage,@JsonKey(name: 'flsco_level') int? flscoLevel, String? notes,@JsonKey(name: 'is_active') bool isActive
});




}
/// @nodoc
class _$StudentCopyWithImpl<$Res>
    implements $StudentCopyWith<$Res> {
  _$StudentCopyWithImpl(this._self, this._then);

  final Student _self;
  final $Res Function(Student) _then;

/// Create a copy of Student
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? lastName = null,Object? firstName = null,Object? displayName = null,Object? pseudoCode = null,Object? groupLabel = freezed,Object? firstLanguage = freezed,Object? flscoLevel = freezed,Object? notes = freezed,Object? isActive = null,}) {
  return _then(Student(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,pseudoCode: null == pseudoCode ? _self.pseudoCode : pseudoCode // ignore: cast_nullable_to_non_nullable
as String,groupLabel: freezed == groupLabel ? _self.groupLabel : groupLabel // ignore: cast_nullable_to_non_nullable
as String?,firstLanguage: freezed == firstLanguage ? _self.firstLanguage : firstLanguage // ignore: cast_nullable_to_non_nullable
as String?,flscoLevel: freezed == flscoLevel ? _self.flscoLevel : flscoLevel // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Student].
extension StudentPatterns on Student {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Student value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Student() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Student value)  $default,){
final _that = this;
switch (_that) {
case _Student():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Student value)?  $default,){
final _that = this;
switch (_that) {
case _Student() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'last_name')  String lastName, @JsonKey(name: 'first_name')  String firstName, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'pseudo_code')  String pseudoCode, @JsonKey(name: 'group_label')  String? groupLabel, @JsonKey(name: 'first_language')  String? firstLanguage, @JsonKey(name: 'flsco_level')  int? flscoLevel,  String? notes, @JsonKey(name: 'is_active')  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Student() when $default != null:
return $default(_that.id,_that.lastName,_that.firstName,_that.displayName,_that.pseudoCode,_that.groupLabel,_that.firstLanguage,_that.flscoLevel,_that.notes,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'last_name')  String lastName, @JsonKey(name: 'first_name')  String firstName, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'pseudo_code')  String pseudoCode, @JsonKey(name: 'group_label')  String? groupLabel, @JsonKey(name: 'first_language')  String? firstLanguage, @JsonKey(name: 'flsco_level')  int? flscoLevel,  String? notes, @JsonKey(name: 'is_active')  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _Student():
return $default(_that.id,_that.lastName,_that.firstName,_that.displayName,_that.pseudoCode,_that.groupLabel,_that.firstLanguage,_that.flscoLevel,_that.notes,_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'last_name')  String lastName, @JsonKey(name: 'first_name')  String firstName, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'pseudo_code')  String pseudoCode, @JsonKey(name: 'group_label')  String? groupLabel, @JsonKey(name: 'first_language')  String? firstLanguage, @JsonKey(name: 'flsco_level')  int? flscoLevel,  String? notes, @JsonKey(name: 'is_active')  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _Student() when $default != null:
return $default(_that.id,_that.lastName,_that.firstName,_that.displayName,_that.pseudoCode,_that.groupLabel,_that.firstLanguage,_that.flscoLevel,_that.notes,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Student implements Student {
  const _Student({required this.id, @JsonKey(name: 'last_name') required this.lastName, @JsonKey(name: 'first_name') required this.firstName, @JsonKey(name: 'display_name') required this.displayName, @JsonKey(name: 'pseudo_code') required this.pseudoCode, @JsonKey(name: 'group_label') this.groupLabel, @JsonKey(name: 'first_language') this.firstLanguage, @JsonKey(name: 'flsco_level') this.flscoLevel, this.notes, @JsonKey(name: 'is_active') this.isActive = true});
  factory _Student.fromJson(Map<String, dynamic> json) => _$StudentFromJson(json);

@override final  String id;
@override@JsonKey(name: 'last_name') final  String lastName;
@override@JsonKey(name: 'first_name') final  String firstName;
@override@JsonKey(name: 'display_name') final  String displayName;
@override@JsonKey(name: 'pseudo_code') final  String pseudoCode;
@override@JsonKey(name: 'group_label') final  String? groupLabel;
@override@JsonKey(name: 'first_language') final  String? firstLanguage;
@override@JsonKey(name: 'flsco_level') final  int? flscoLevel;
@override final  String? notes;
@override@JsonKey(name: 'is_active') final  bool isActive;

/// Create a copy of Student
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StudentCopyWith<_Student> get copyWith => __$StudentCopyWithImpl<_Student>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StudentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Student&&(identical(other.id, id) || other.id == id)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.pseudoCode, pseudoCode) || other.pseudoCode == pseudoCode)&&(identical(other.groupLabel, groupLabel) || other.groupLabel == groupLabel)&&(identical(other.firstLanguage, firstLanguage) || other.firstLanguage == firstLanguage)&&(identical(other.flscoLevel, flscoLevel) || other.flscoLevel == flscoLevel)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,lastName,firstName,displayName,pseudoCode,groupLabel,firstLanguage,flscoLevel,notes,isActive);
}

@override
String toString() {
    return 'Student(id: $id, lastName: $lastName, firstName: $firstName, displayName: $displayName, pseudoCode: $pseudoCode, groupLabel: $groupLabel, firstLanguage: $firstLanguage, flscoLevel: $flscoLevel, notes: $notes, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$StudentCopyWith<$Res> implements $StudentCopyWith<$Res> {
  factory _$StudentCopyWith(_Student value, $Res Function(_Student) _then) = __$StudentCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'last_name') String lastName,@JsonKey(name: 'first_name') String firstName,@JsonKey(name: 'display_name') String displayName,@JsonKey(name: 'pseudo_code') String pseudoCode,@JsonKey(name: 'group_label') String? groupLabel,@JsonKey(name: 'first_language') String? firstLanguage,@JsonKey(name: 'flsco_level') int? flscoLevel, String? notes,@JsonKey(name: 'is_active') bool isActive
});




}
/// @nodoc
class __$StudentCopyWithImpl<$Res>
    implements _$StudentCopyWith<$Res> {
  __$StudentCopyWithImpl(this._self, this._then);

  final _Student _self;
  final $Res Function(_Student) _then;

/// Create a copy of Student
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? lastName = null,Object? firstName = null,Object? displayName = null,Object? pseudoCode = null,Object? groupLabel = freezed,Object? firstLanguage = freezed,Object? flscoLevel = freezed,Object? notes = freezed,Object? isActive = null,}) {
  return _then(_Student(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,pseudoCode: null == pseudoCode ? _self.pseudoCode : pseudoCode // ignore: cast_nullable_to_non_nullable
as String,groupLabel: freezed == groupLabel ? _self.groupLabel : groupLabel // ignore: cast_nullable_to_non_nullable
as String?,firstLanguage: freezed == firstLanguage ? _self.firstLanguage : firstLanguage // ignore: cast_nullable_to_non_nullable
as String?,flscoLevel: freezed == flscoLevel ? _self.flscoLevel : flscoLevel // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
