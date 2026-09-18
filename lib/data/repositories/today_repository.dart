import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/result/result.dart';
import '../../models/journal_entry.dart';
import '../../models/schedule_slot.dart';

/// Lit l'EDT et le cahier journal d'une date donnée.
class TodayRepository {
  const TodayRepository(this._client);

  final SupabaseClient _client;

  Future<String> _currentClassId() async {
    final rows = await _client.from('classes').select('id').limit(1);
    if (rows.isEmpty) {
      throw const AppException('Aucune classe associée à ce compte.');
    }
    return rows.first['id'] as String;
  }

  Future<bool> isNonTeachingDay(DateTime date) async {
    final rows = await _client.from('classes').select('non_teaching_days').limit(1);
    if (rows.isEmpty) return false;
    final list = (rows.first['non_teaching_days'] as List?)?.cast<String>() ?? const [];
    return list.contains(_isoDate(date));
  }

  /// Point d'entrée unique de l'EDT (§3.5/§6.7) : la version valide à la date
  /// demandée, jamais la version "actuelle" par défaut. Tout code qui affiche
  /// ou génère un emploi du temps doit passer par cette fonction, pas par une
  /// lecture directe de `schedule_slots`.
  Future<List<ScheduleSlot>> scheduleForDate(DateTime date) async {
    final classId = await _currentClassId();
    final rows = await _client.rpc<List<dynamic>>(
      'get_schedule_for_date',
      params: {'p_class_id': classId, 'p_date': _isoDate(date)},
    );
    return rows
        .map((row) => ScheduleSlot.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<List<JournalEntry>> journalEntriesForDate(DateTime date) async {
    final classId = await _currentClassId();
    final iso = _isoDate(date);

    final days = await _client
        .from('journal_days')
        .select('id')
        .eq('class_id', classId)
        .eq('date', iso)
        .limit(1);

    if (days.isEmpty) return const [];
    final dayId = days.first['id'] as String;

    final entries = await _client
        .from('journal_entries')
        .select()
        .eq('day_id', dayId)
        .order('start_time');

    return entries.map(JournalEntry.fromJson).toList();
  }

  static String _isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
