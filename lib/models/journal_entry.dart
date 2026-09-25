import 'package:freezed_annotation/freezed_annotation.dart';

part 'journal_entry.freezed.dart';
part 'journal_entry.g.dart';

/// Reflète `journal_entries` (docs/PLAN_EXECUTION.md §6.4).
/// `deroulement_steps` est ce que l'enseignante voit, modifie et réordonne.
/// Pour une séance générée par l'IA, il est dérivé des 5 phases (`deroulement`,
/// jsonb, jamais relu par l'app) au moment de la validation.
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
