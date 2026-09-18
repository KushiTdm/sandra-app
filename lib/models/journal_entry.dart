import 'package:freezed_annotation/freezed_annotation.dart';

part 'journal_entry.freezed.dart';
part 'journal_entry.g.dart';

/// Reflète `journal_entries` (docs/PLAN_EXECUTION.md §6.4).
/// `deroulement` (5 phases, séances générées par l'IA) n'existe pas encore en
/// base (§3.6, écart assumé) : seul `deroulement_steps` est lu pour l'instant.
@freezed
abstract class JournalEntry with _$JournalEntry {
  const factory JournalEntry({
    required String id,
    @JsonKey(name: 'day_id') required String dayId,
    @JsonKey(name: 'start_time') String? startTime,
    @JsonKey(name: 'end_time') String? endTime,
    @JsonKey(name: 'subject_label') required String subjectLabel,
    @JsonKey(name: 'domain_code') String? domainCode,
    @JsonKey(name: 'group_label') String? groupLabel,
    String? title,
    @JsonKey(name: 'competence_bo') String? competenceBo,
    String? objective,
    @JsonKey(name: 'deroulement_steps') @Default([]) List<String> deroulementSteps,
    String? differenciation,
    @Default([]) List<String> materiel,
    required String status,
    required String origin,
  }) = _JournalEntry;

  factory JournalEntry.fromJson(Map<String, dynamic> json) =>
      _$JournalEntryFromJson(json);
}
