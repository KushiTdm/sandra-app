// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_JournalEntry _$JournalEntryFromJson(Map<String, dynamic> json) =>
    _JournalEntry(
      id: json['id'] as String,
      dayId: json['day_id'] as String,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      subjectLabel: json['subject_label'] as String,
      domainCode: json['domain_code'] as String?,
      groupLabel: json['group_label'] as String?,
      title: json['title'] as String?,
      competenceBo: json['competence_bo'] as String?,
      objective: json['objective'] as String?,
      deroulementSteps:
          (json['deroulement_steps'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      differenciation: json['differenciation'] as String?,
      materiel:
          (json['materiel'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      status: json['status'] as String,
      origin: json['origin'] as String,
    );

Map<String, dynamic> _$JournalEntryToJson(_JournalEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'day_id': instance.dayId,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'subject_label': instance.subjectLabel,
      'domain_code': instance.domainCode,
      'group_label': instance.groupLabel,
      'title': instance.title,
      'competence_bo': instance.competenceBo,
      'objective': instance.objective,
      'deroulement_steps': instance.deroulementSteps,
      'differenciation': instance.differenciation,
      'materiel': instance.materiel,
      'status': instance.status,
      'origin': instance.origin,
    };
