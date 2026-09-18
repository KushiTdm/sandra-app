// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'journal_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$JournalEntry {

 String get id;@JsonKey(name: 'day_id') String get dayId;@JsonKey(name: 'start_time') String? get startTime;@JsonKey(name: 'end_time') String? get endTime;@JsonKey(name: 'subject_label') String get subjectLabel;@JsonKey(name: 'domain_code') String? get domainCode;@JsonKey(name: 'group_label') String? get groupLabel; String? get title;@JsonKey(name: 'competence_bo') String? get competenceBo; String? get objective;@JsonKey(name: 'deroulement_steps') List<String> get deroulementSteps; String? get differenciation; List<String> get materiel; String get status; String get origin;
/// Create a copy of JournalEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JournalEntryCopyWith<JournalEntry> get copyWith => _$JournalEntryCopyWithImpl<JournalEntry>(this as JournalEntry, _$identity);

  /// Serializes this JournalEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as JournalEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JournalEntry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.dayId, _this.dayId) || other.dayId == _this.dayId)&&(identical(other.startTime, _this.startTime) || other.startTime == _this.startTime)&&(identical(other.endTime, _this.endTime) || other.endTime == _this.endTime)&&(identical(other.subjectLabel, _this.subjectLabel) || other.subjectLabel == _this.subjectLabel)&&(identical(other.domainCode, _this.domainCode) || other.domainCode == _this.domainCode)&&(identical(other.groupLabel, _this.groupLabel) || other.groupLabel == _this.groupLabel)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.competenceBo, _this.competenceBo) || other.competenceBo == _this.competenceBo)&&(identical(other.objective, _this.objective) || other.objective == _this.objective)&&const DeepCollectionEquality().equals(other.deroulementSteps, _this.deroulementSteps)&&(identical(other.differenciation, _this.differenciation) || other.differenciation == _this.differenciation)&&const DeepCollectionEquality().equals(other.materiel, _this.materiel)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.origin, _this.origin) || other.origin == _this.origin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as JournalEntry;
  return Object.hash(runtimeType,_this.id,_this.dayId,_this.startTime,_this.endTime,_this.subjectLabel,_this.domainCode,_this.groupLabel,_this.title,_this.competenceBo,_this.objective,const DeepCollectionEquality().hash(_this.deroulementSteps),_this.differenciation,const DeepCollectionEquality().hash(_this.materiel),_this.status,_this.origin);
}

@override
String toString() {
  final _this = this as JournalEntry;
  return 'JournalEntry(id: ${_this.id}, dayId: ${_this.dayId}, startTime: ${_this.startTime}, endTime: ${_this.endTime}, subjectLabel: ${_this.subjectLabel}, domainCode: ${_this.domainCode}, groupLabel: ${_this.groupLabel}, title: ${_this.title}, competenceBo: ${_this.competenceBo}, objective: ${_this.objective}, deroulementSteps: ${_this.deroulementSteps}, differenciation: ${_this.differenciation}, materiel: ${_this.materiel}, status: ${_this.status}, origin: ${_this.origin})';
}


}

/// @nodoc
abstract mixin class $JournalEntryCopyWith<$Res>  {
  factory $JournalEntryCopyWith(JournalEntry value, $Res Function(JournalEntry) _then) = _$JournalEntryCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'day_id') String dayId,@JsonKey(name: 'start_time') String? startTime,@JsonKey(name: 'end_time') String? endTime,@JsonKey(name: 'subject_label') String subjectLabel,@JsonKey(name: 'domain_code') String? domainCode,@JsonKey(name: 'group_label') String? groupLabel, String? title,@JsonKey(name: 'competence_bo') String? competenceBo, String? objective,@JsonKey(name: 'deroulement_steps') List<String> deroulementSteps, String? differenciation, List<String> materiel, String status, String origin
});




}
/// @nodoc
class _$JournalEntryCopyWithImpl<$Res>
    implements $JournalEntryCopyWith<$Res> {
  _$JournalEntryCopyWithImpl(this._self, this._then);

  final JournalEntry _self;
  final $Res Function(JournalEntry) _then;

/// Create a copy of JournalEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? dayId = null,Object? startTime = freezed,Object? endTime = freezed,Object? subjectLabel = null,Object? domainCode = freezed,Object? groupLabel = freezed,Object? title = freezed,Object? competenceBo = freezed,Object? objective = freezed,Object? deroulementSteps = null,Object? differenciation = freezed,Object? materiel = null,Object? status = null,Object? origin = null,}) {
  return _then(JournalEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,dayId: null == dayId ? _self.dayId : dayId // ignore: cast_nullable_to_non_nullable
as String,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String?,subjectLabel: null == subjectLabel ? _self.subjectLabel : subjectLabel // ignore: cast_nullable_to_non_nullable
as String,domainCode: freezed == domainCode ? _self.domainCode : domainCode // ignore: cast_nullable_to_non_nullable
as String?,groupLabel: freezed == groupLabel ? _self.groupLabel : groupLabel // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,competenceBo: freezed == competenceBo ? _self.competenceBo : competenceBo // ignore: cast_nullable_to_non_nullable
as String?,objective: freezed == objective ? _self.objective : objective // ignore: cast_nullable_to_non_nullable
as String?,deroulementSteps: null == deroulementSteps ? _self.deroulementSteps : deroulementSteps // ignore: cast_nullable_to_non_nullable
as List<String>,differenciation: freezed == differenciation ? _self.differenciation : differenciation // ignore: cast_nullable_to_non_nullable
as String?,materiel: null == materiel ? _self.materiel : materiel // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [JournalEntry].
extension JournalEntryPatterns on JournalEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JournalEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JournalEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JournalEntry value)  $default,){
final _that = this;
switch (_that) {
case _JournalEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JournalEntry value)?  $default,){
final _that = this;
switch (_that) {
case _JournalEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'day_id')  String dayId, @JsonKey(name: 'start_time')  String? startTime, @JsonKey(name: 'end_time')  String? endTime, @JsonKey(name: 'subject_label')  String subjectLabel, @JsonKey(name: 'domain_code')  String? domainCode, @JsonKey(name: 'group_label')  String? groupLabel,  String? title, @JsonKey(name: 'competence_bo')  String? competenceBo,  String? objective, @JsonKey(name: 'deroulement_steps')  List<String> deroulementSteps,  String? differenciation,  List<String> materiel,  String status,  String origin)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JournalEntry() when $default != null:
return $default(_that.id,_that.dayId,_that.startTime,_that.endTime,_that.subjectLabel,_that.domainCode,_that.groupLabel,_that.title,_that.competenceBo,_that.objective,_that.deroulementSteps,_that.differenciation,_that.materiel,_that.status,_that.origin);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'day_id')  String dayId, @JsonKey(name: 'start_time')  String? startTime, @JsonKey(name: 'end_time')  String? endTime, @JsonKey(name: 'subject_label')  String subjectLabel, @JsonKey(name: 'domain_code')  String? domainCode, @JsonKey(name: 'group_label')  String? groupLabel,  String? title, @JsonKey(name: 'competence_bo')  String? competenceBo,  String? objective, @JsonKey(name: 'deroulement_steps')  List<String> deroulementSteps,  String? differenciation,  List<String> materiel,  String status,  String origin)  $default,) {final _that = this;
switch (_that) {
case _JournalEntry():
return $default(_that.id,_that.dayId,_that.startTime,_that.endTime,_that.subjectLabel,_that.domainCode,_that.groupLabel,_that.title,_that.competenceBo,_that.objective,_that.deroulementSteps,_that.differenciation,_that.materiel,_that.status,_that.origin);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'day_id')  String dayId, @JsonKey(name: 'start_time')  String? startTime, @JsonKey(name: 'end_time')  String? endTime, @JsonKey(name: 'subject_label')  String subjectLabel, @JsonKey(name: 'domain_code')  String? domainCode, @JsonKey(name: 'group_label')  String? groupLabel,  String? title, @JsonKey(name: 'competence_bo')  String? competenceBo,  String? objective, @JsonKey(name: 'deroulement_steps')  List<String> deroulementSteps,  String? differenciation,  List<String> materiel,  String status,  String origin)?  $default,) {final _that = this;
switch (_that) {
case _JournalEntry() when $default != null:
return $default(_that.id,_that.dayId,_that.startTime,_that.endTime,_that.subjectLabel,_that.domainCode,_that.groupLabel,_that.title,_that.competenceBo,_that.objective,_that.deroulementSteps,_that.differenciation,_that.materiel,_that.status,_that.origin);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _JournalEntry implements JournalEntry {
  const _JournalEntry({required this.id, @JsonKey(name: 'day_id') required this.dayId, @JsonKey(name: 'start_time') this.startTime, @JsonKey(name: 'end_time') this.endTime, @JsonKey(name: 'subject_label') required this.subjectLabel, @JsonKey(name: 'domain_code') this.domainCode, @JsonKey(name: 'group_label') this.groupLabel, this.title, @JsonKey(name: 'competence_bo') this.competenceBo, this.objective, @JsonKey(name: 'deroulement_steps')  List<String> deroulementSteps = const [], this.differenciation,  List<String> materiel = const [], required this.status, required this.origin}): _deroulementSteps = deroulementSteps,_materiel = materiel;
  factory _JournalEntry.fromJson(Map<String, dynamic> json) => _$JournalEntryFromJson(json);

@override final  String id;
@override@JsonKey(name: 'day_id') final  String dayId;
@override@JsonKey(name: 'start_time') final  String? startTime;
@override@JsonKey(name: 'end_time') final  String? endTime;
@override@JsonKey(name: 'subject_label') final  String subjectLabel;
@override@JsonKey(name: 'domain_code') final  String? domainCode;
@override@JsonKey(name: 'group_label') final  String? groupLabel;
@override final  String? title;
@override@JsonKey(name: 'competence_bo') final  String? competenceBo;
@override final  String? objective;
 final  List<String> _deroulementSteps;
@override@JsonKey(name: 'deroulement_steps') List<String> get deroulementSteps {
  if (_deroulementSteps is EqualUnmodifiableListView) return _deroulementSteps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_deroulementSteps);
}

@override final  String? differenciation;
 final  List<String> _materiel;
@override@JsonKey() List<String> get materiel {
  if (_materiel is EqualUnmodifiableListView) return _materiel;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_materiel);
}

@override final  String status;
@override final  String origin;

/// Create a copy of JournalEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JournalEntryCopyWith<_JournalEntry> get copyWith => __$JournalEntryCopyWithImpl<_JournalEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JournalEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _JournalEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.dayId, dayId) || other.dayId == dayId)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.subjectLabel, subjectLabel) || other.subjectLabel == subjectLabel)&&(identical(other.domainCode, domainCode) || other.domainCode == domainCode)&&(identical(other.groupLabel, groupLabel) || other.groupLabel == groupLabel)&&(identical(other.title, title) || other.title == title)&&(identical(other.competenceBo, competenceBo) || other.competenceBo == competenceBo)&&(identical(other.objective, objective) || other.objective == objective)&&const DeepCollectionEquality().equals(other.deroulementSteps, _deroulementSteps)&&(identical(other.differenciation, differenciation) || other.differenciation == differenciation)&&const DeepCollectionEquality().equals(other.materiel, _materiel)&&(identical(other.status, status) || other.status == status)&&(identical(other.origin, origin) || other.origin == origin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,dayId,startTime,endTime,subjectLabel,domainCode,groupLabel,title,competenceBo,objective,const DeepCollectionEquality().hash(_deroulementSteps),differenciation,const DeepCollectionEquality().hash(_materiel),status,origin);
}

@override
String toString() {
    return 'JournalEntry(id: $id, dayId: $dayId, startTime: $startTime, endTime: $endTime, subjectLabel: $subjectLabel, domainCode: $domainCode, groupLabel: $groupLabel, title: $title, competenceBo: $competenceBo, objective: $objective, deroulementSteps: $deroulementSteps, differenciation: $differenciation, materiel: $materiel, status: $status, origin: $origin)';
}


}

/// @nodoc
abstract mixin class _$JournalEntryCopyWith<$Res> implements $JournalEntryCopyWith<$Res> {
  factory _$JournalEntryCopyWith(_JournalEntry value, $Res Function(_JournalEntry) _then) = __$JournalEntryCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'day_id') String dayId,@JsonKey(name: 'start_time') String? startTime,@JsonKey(name: 'end_time') String? endTime,@JsonKey(name: 'subject_label') String subjectLabel,@JsonKey(name: 'domain_code') String? domainCode,@JsonKey(name: 'group_label') String? groupLabel, String? title,@JsonKey(name: 'competence_bo') String? competenceBo, String? objective,@JsonKey(name: 'deroulement_steps') List<String> deroulementSteps, String? differenciation, List<String> materiel, String status, String origin
});




}
/// @nodoc
class __$JournalEntryCopyWithImpl<$Res>
    implements _$JournalEntryCopyWith<$Res> {
  __$JournalEntryCopyWithImpl(this._self, this._then);

  final _JournalEntry _self;
  final $Res Function(_JournalEntry) _then;

/// Create a copy of JournalEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? dayId = null,Object? startTime = freezed,Object? endTime = freezed,Object? subjectLabel = null,Object? domainCode = freezed,Object? groupLabel = freezed,Object? title = freezed,Object? competenceBo = freezed,Object? objective = freezed,Object? deroulementSteps = null,Object? differenciation = freezed,Object? materiel = null,Object? status = null,Object? origin = null,}) {
  return _then(_JournalEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,dayId: null == dayId ? _self.dayId : dayId // ignore: cast_nullable_to_non_nullable
as String,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String?,subjectLabel: null == subjectLabel ? _self.subjectLabel : subjectLabel // ignore: cast_nullable_to_non_nullable
as String,domainCode: freezed == domainCode ? _self.domainCode : domainCode // ignore: cast_nullable_to_non_nullable
as String?,groupLabel: freezed == groupLabel ? _self.groupLabel : groupLabel // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,competenceBo: freezed == competenceBo ? _self.competenceBo : competenceBo // ignore: cast_nullable_to_non_nullable
as String?,objective: freezed == objective ? _self.objective : objective // ignore: cast_nullable_to_non_nullable
as String?,deroulementSteps: null == deroulementSteps ? _self._deroulementSteps : deroulementSteps // ignore: cast_nullable_to_non_nullable
as List<String>,differenciation: freezed == differenciation ? _self.differenciation : differenciation // ignore: cast_nullable_to_non_nullable
as String?,materiel: null == materiel ? _self._materiel : materiel // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
