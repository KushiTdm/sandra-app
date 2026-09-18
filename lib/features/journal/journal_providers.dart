import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/supabase/supabase_bootstrap.dart';
import '../../data/repositories/journal_repository.dart';
import '../../data/repositories/today_repository.dart';
import '../../models/journal_entry.dart';
import '../../models/schedule_slot.dart';

final journalRepositoryProvider = Provider<JournalRepository>((ref) => JournalRepository(supabase));

final journalClassIdProvider = FutureProvider<String>((ref) {
  return ref.watch(journalRepositoryProvider).currentClassId();
});

final _scheduleRepositoryProvider = Provider<TodayRepository>((ref) => TodayRepository(supabase));

/// EDT du jour demandé, via `get_schedule_for_date` (§3.5) — jamais un
/// horaire recalculé localement.
final scheduleForDateProvider =
    FutureProvider.autoDispose.family<List<ScheduleSlot>, DateTime>((ref, date) {
  return ref.watch(_scheduleRepositoryProvider).scheduleForDate(date);
});

final isNonTeachingDayForDateProvider =
    FutureProvider.autoDispose.family<bool, DateTime>((ref, date) {
  return ref.watch(_scheduleRepositoryProvider).isNonTeachingDay(date);
});

class DayJournalState {
  const DayJournalState({required this.dayId, required this.entries});

  /// `null` si aucune journée n'a encore été créée pour cette date (rien à
  /// afficher, mais pas une erreur — voir `ensureDay`).
  final String? dayId;
  final List<JournalEntry> entries;
}

final dayJournalProvider =
    FutureProvider.autoDispose.family<DayJournalState, DateTime>((ref, date) async {
  final classId = await ref.watch(journalClassIdProvider.future);
  final repo = ref.watch(journalRepositoryProvider);
  final dayId = await repo.findDayId(classId, date);
  if (dayId == null) return const DayJournalState(dayId: null, entries: []);
  final entries = await repo.entriesForDay(dayId);
  return DayJournalState(dayId: dayId, entries: entries);
});
