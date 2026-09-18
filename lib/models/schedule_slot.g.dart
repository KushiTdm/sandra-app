// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_slot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ScheduleSlot _$ScheduleSlotFromJson(Map<String, dynamic> json) =>
    _ScheduleSlot(
      id: json['id'] as String,
      dayOfWeek: (json['day_of_week'] as num).toInt(),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      subjectLabel: json['subject_label'] as String,
      domainCode: json['domain_code'] as String?,
      groupLabel: json['group_label'] as String?,
      taughtBy: json['taught_by'] as String,
      isBreak: json['is_break'] as bool,
    );

Map<String, dynamic> _$ScheduleSlotToJson(_ScheduleSlot instance) =>
    <String, dynamic>{
      'id': instance.id,
      'day_of_week': instance.dayOfWeek,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'subject_label': instance.subjectLabel,
      'domain_code': instance.domainCode,
      'group_label': instance.groupLabel,
      'taught_by': instance.taughtBy,
      'is_break': instance.isBreak,
    };
