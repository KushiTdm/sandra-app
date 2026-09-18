// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Student _$StudentFromJson(Map<String, dynamic> json) => _Student(
  id: json['id'] as String,
  lastName: json['last_name'] as String,
  firstName: json['first_name'] as String,
  displayName: json['display_name'] as String,
  pseudoCode: json['pseudo_code'] as String,
  groupLabel: json['group_label'] as String?,
  firstLanguage: json['first_language'] as String?,
  flscoLevel: (json['flsco_level'] as num?)?.toInt(),
  notes: json['notes'] as String?,
  isActive: json['is_active'] as bool? ?? true,
);

Map<String, dynamic> _$StudentToJson(_Student instance) => <String, dynamic>{
  'id': instance.id,
  'last_name': instance.lastName,
  'first_name': instance.firstName,
  'display_name': instance.displayName,
  'pseudo_code': instance.pseudoCode,
  'group_label': instance.groupLabel,
  'first_language': instance.firstLanguage,
  'flsco_level': instance.flscoLevel,
  'notes': instance.notes,
  'is_active': instance.isActive,
};
