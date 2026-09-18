import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule_slot.freezed.dart';
part 'schedule_slot.g.dart';

/// Reflète `schedule_slots` (docs/PLAN_EXECUTION.md §6.2).
/// `dayOfWeek` : 1 = lundi … 5 = vendredi.
@freezed
abstract class ScheduleSlot with _$ScheduleSlot {
  const factory ScheduleSlot({
    required String id,
    @JsonKey(name: 'day_of_week') required int dayOfWeek,
    @JsonKey(name: 'start_time') required String startTime,
    @JsonKey(name: 'end_time') required String endTime,
    @JsonKey(name: 'subject_label') required String subjectLabel,
    @JsonKey(name: 'domain_code') String? domainCode,
    @JsonKey(name: 'group_label') String? groupLabel,
    @JsonKey(name: 'taught_by') required String taughtBy,
    @JsonKey(name: 'is_break') required bool isBreak,
  }) = _ScheduleSlot;

  factory ScheduleSlot.fromJson(Map<String, dynamic> json) =>
      _$ScheduleSlotFromJson(json);
}
