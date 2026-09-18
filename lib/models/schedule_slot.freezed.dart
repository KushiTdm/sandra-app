// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_slot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScheduleSlot {

 String get id;@JsonKey(name: 'day_of_week') int get dayOfWeek;@JsonKey(name: 'start_time') String get startTime;@JsonKey(name: 'end_time') String get endTime;@JsonKey(name: 'subject_label') String get subjectLabel;@JsonKey(name: 'domain_code') String? get domainCode;@JsonKey(name: 'group_label') String? get groupLabel;@JsonKey(name: 'taught_by') String get taughtBy;@JsonKey(name: 'is_break') bool get isBreak;
/// Create a copy of ScheduleSlot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduleSlotCopyWith<ScheduleSlot> get copyWith => _$ScheduleSlotCopyWithImpl<ScheduleSlot>(this as ScheduleSlot, _$identity);

  /// Serializes this ScheduleSlot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ScheduleSlot;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduleSlot&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.dayOfWeek, _this.dayOfWeek) || other.dayOfWeek == _this.dayOfWeek)&&(identical(other.startTime, _this.startTime) || other.startTime == _this.startTime)&&(identical(other.endTime, _this.endTime) || other.endTime == _this.endTime)&&(identical(other.subjectLabel, _this.subjectLabel) || other.subjectLabel == _this.subjectLabel)&&(identical(other.domainCode, _this.domainCode) || other.domainCode == _this.domainCode)&&(identical(other.groupLabel, _this.groupLabel) || other.groupLabel == _this.groupLabel)&&(identical(other.taughtBy, _this.taughtBy) || other.taughtBy == _this.taughtBy)&&(identical(other.isBreak, _this.isBreak) || other.isBreak == _this.isBreak));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ScheduleSlot;
  return Object.hash(runtimeType,_this.id,_this.dayOfWeek,_this.startTime,_this.endTime,_this.subjectLabel,_this.domainCode,_this.groupLabel,_this.taughtBy,_this.isBreak);
}

@override
String toString() {
  final _this = this as ScheduleSlot;
  return 'ScheduleSlot(id: ${_this.id}, dayOfWeek: ${_this.dayOfWeek}, startTime: ${_this.startTime}, endTime: ${_this.endTime}, subjectLabel: ${_this.subjectLabel}, domainCode: ${_this.domainCode}, groupLabel: ${_this.groupLabel}, taughtBy: ${_this.taughtBy}, isBreak: ${_this.isBreak})';
}


}

/// @nodoc
abstract mixin class $ScheduleSlotCopyWith<$Res>  {
  factory $ScheduleSlotCopyWith(ScheduleSlot value, $Res Function(ScheduleSlot) _then) = _$ScheduleSlotCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'day_of_week') int dayOfWeek,@JsonKey(name: 'start_time') String startTime,@JsonKey(name: 'end_time') String endTime,@JsonKey(name: 'subject_label') String subjectLabel,@JsonKey(name: 'domain_code') String? domainCode,@JsonKey(name: 'group_label') String? groupLabel,@JsonKey(name: 'taught_by') String taughtBy,@JsonKey(name: 'is_break') bool isBreak
});




}
/// @nodoc
class _$ScheduleSlotCopyWithImpl<$Res>
    implements $ScheduleSlotCopyWith<$Res> {
  _$ScheduleSlotCopyWithImpl(this._self, this._then);

  final ScheduleSlot _self;
  final $Res Function(ScheduleSlot) _then;

/// Create a copy of ScheduleSlot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? dayOfWeek = null,Object? startTime = null,Object? endTime = null,Object? subjectLabel = null,Object? domainCode = freezed,Object? groupLabel = freezed,Object? taughtBy = null,Object? isBreak = null,}) {
  return _then(ScheduleSlot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as int,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,subjectLabel: null == subjectLabel ? _self.subjectLabel : subjectLabel // ignore: cast_nullable_to_non_nullable
as String,domainCode: freezed == domainCode ? _self.domainCode : domainCode // ignore: cast_nullable_to_non_nullable
as String?,groupLabel: freezed == groupLabel ? _self.groupLabel : groupLabel // ignore: cast_nullable_to_non_nullable
as String?,taughtBy: null == taughtBy ? _self.taughtBy : taughtBy // ignore: cast_nullable_to_non_nullable
as String,isBreak: null == isBreak ? _self.isBreak : isBreak // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ScheduleSlot].
extension ScheduleSlotPatterns on ScheduleSlot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScheduleSlot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScheduleSlot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScheduleSlot value)  $default,){
final _that = this;
switch (_that) {
case _ScheduleSlot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScheduleSlot value)?  $default,){
final _that = this;
switch (_that) {
case _ScheduleSlot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'day_of_week')  int dayOfWeek, @JsonKey(name: 'start_time')  String startTime, @JsonKey(name: 'end_time')  String endTime, @JsonKey(name: 'subject_label')  String subjectLabel, @JsonKey(name: 'domain_code')  String? domainCode, @JsonKey(name: 'group_label')  String? groupLabel, @JsonKey(name: 'taught_by')  String taughtBy, @JsonKey(name: 'is_break')  bool isBreak)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScheduleSlot() when $default != null:
return $default(_that.id,_that.dayOfWeek,_that.startTime,_that.endTime,_that.subjectLabel,_that.domainCode,_that.groupLabel,_that.taughtBy,_that.isBreak);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'day_of_week')  int dayOfWeek, @JsonKey(name: 'start_time')  String startTime, @JsonKey(name: 'end_time')  String endTime, @JsonKey(name: 'subject_label')  String subjectLabel, @JsonKey(name: 'domain_code')  String? domainCode, @JsonKey(name: 'group_label')  String? groupLabel, @JsonKey(name: 'taught_by')  String taughtBy, @JsonKey(name: 'is_break')  bool isBreak)  $default,) {final _that = this;
switch (_that) {
case _ScheduleSlot():
return $default(_that.id,_that.dayOfWeek,_that.startTime,_that.endTime,_that.subjectLabel,_that.domainCode,_that.groupLabel,_that.taughtBy,_that.isBreak);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'day_of_week')  int dayOfWeek, @JsonKey(name: 'start_time')  String startTime, @JsonKey(name: 'end_time')  String endTime, @JsonKey(name: 'subject_label')  String subjectLabel, @JsonKey(name: 'domain_code')  String? domainCode, @JsonKey(name: 'group_label')  String? groupLabel, @JsonKey(name: 'taught_by')  String taughtBy, @JsonKey(name: 'is_break')  bool isBreak)?  $default,) {final _that = this;
switch (_that) {
case _ScheduleSlot() when $default != null:
return $default(_that.id,_that.dayOfWeek,_that.startTime,_that.endTime,_that.subjectLabel,_that.domainCode,_that.groupLabel,_that.taughtBy,_that.isBreak);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScheduleSlot implements ScheduleSlot {
  const _ScheduleSlot({required this.id, @JsonKey(name: 'day_of_week') required this.dayOfWeek, @JsonKey(name: 'start_time') required this.startTime, @JsonKey(name: 'end_time') required this.endTime, @JsonKey(name: 'subject_label') required this.subjectLabel, @JsonKey(name: 'domain_code') this.domainCode, @JsonKey(name: 'group_label') this.groupLabel, @JsonKey(name: 'taught_by') required this.taughtBy, @JsonKey(name: 'is_break') required this.isBreak});
  factory _ScheduleSlot.fromJson(Map<String, dynamic> json) => _$ScheduleSlotFromJson(json);

@override final  String id;
@override@JsonKey(name: 'day_of_week') final  int dayOfWeek;
@override@JsonKey(name: 'start_time') final  String startTime;
@override@JsonKey(name: 'end_time') final  String endTime;
@override@JsonKey(name: 'subject_label') final  String subjectLabel;
@override@JsonKey(name: 'domain_code') final  String? domainCode;
@override@JsonKey(name: 'group_label') final  String? groupLabel;
@override@JsonKey(name: 'taught_by') final  String taughtBy;
@override@JsonKey(name: 'is_break') final  bool isBreak;

/// Create a copy of ScheduleSlot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScheduleSlotCopyWith<_ScheduleSlot> get copyWith => __$ScheduleSlotCopyWithImpl<_ScheduleSlot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScheduleSlotToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScheduleSlot&&(identical(other.id, id) || other.id == id)&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.subjectLabel, subjectLabel) || other.subjectLabel == subjectLabel)&&(identical(other.domainCode, domainCode) || other.domainCode == domainCode)&&(identical(other.groupLabel, groupLabel) || other.groupLabel == groupLabel)&&(identical(other.taughtBy, taughtBy) || other.taughtBy == taughtBy)&&(identical(other.isBreak, isBreak) || other.isBreak == isBreak));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,dayOfWeek,startTime,endTime,subjectLabel,domainCode,groupLabel,taughtBy,isBreak);
}

@override
String toString() {
    return 'ScheduleSlot(id: $id, dayOfWeek: $dayOfWeek, startTime: $startTime, endTime: $endTime, subjectLabel: $subjectLabel, domainCode: $domainCode, groupLabel: $groupLabel, taughtBy: $taughtBy, isBreak: $isBreak)';
}


}

/// @nodoc
abstract mixin class _$ScheduleSlotCopyWith<$Res> implements $ScheduleSlotCopyWith<$Res> {
  factory _$ScheduleSlotCopyWith(_ScheduleSlot value, $Res Function(_ScheduleSlot) _then) = __$ScheduleSlotCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'day_of_week') int dayOfWeek,@JsonKey(name: 'start_time') String startTime,@JsonKey(name: 'end_time') String endTime,@JsonKey(name: 'subject_label') String subjectLabel,@JsonKey(name: 'domain_code') String? domainCode,@JsonKey(name: 'group_label') String? groupLabel,@JsonKey(name: 'taught_by') String taughtBy,@JsonKey(name: 'is_break') bool isBreak
});




}
/// @nodoc
class __$ScheduleSlotCopyWithImpl<$Res>
    implements _$ScheduleSlotCopyWith<$Res> {
  __$ScheduleSlotCopyWithImpl(this._self, this._then);

  final _ScheduleSlot _self;
  final $Res Function(_ScheduleSlot) _then;

/// Create a copy of ScheduleSlot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? dayOfWeek = null,Object? startTime = null,Object? endTime = null,Object? subjectLabel = null,Object? domainCode = freezed,Object? groupLabel = freezed,Object? taughtBy = null,Object? isBreak = null,}) {
  return _then(_ScheduleSlot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as int,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,subjectLabel: null == subjectLabel ? _self.subjectLabel : subjectLabel // ignore: cast_nullable_to_non_nullable
as String,domainCode: freezed == domainCode ? _self.domainCode : domainCode // ignore: cast_nullable_to_non_nullable
as String?,groupLabel: freezed == groupLabel ? _self.groupLabel : groupLabel // ignore: cast_nullable_to_non_nullable
as String?,taughtBy: null == taughtBy ? _self.taughtBy : taughtBy // ignore: cast_nullable_to_non_nullable
as String,isBreak: null == isBreak ? _self.isBreak : isBreak // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
