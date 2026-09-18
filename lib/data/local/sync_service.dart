import 'dart:async';
import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_database.dart';
import 'connectivity_service.dart';

class SyncResult {
  const SyncResult({required this.pushed, required this.failed});
  final int pushed;
  final int failed;
}

/// Pousse vers Supabase ce que l'appel, le signalement et le bilan du soir
/// ont écrit en local pendant que le réseau manquait (Lot 4, §3.5). Se
/// déclenche au retour de connexion, à intervalle de repli, et peut être
/// appelé manuellement (bandeau de statut). N'écrit jamais avec une clé
/// service-role : `_client` porte le JWT de la session en cours, la RLS
/// s'applique exactement comme pour un appel en ligne (R4).
///
/// Chaque ligne dirty est traitée indépendamment : l'échec de l'une (ex.
/// coupure réseau en plein milieu) ne bloque pas les autres, elle reste
/// simplement `dirty` pour le prochain passage.
class SyncService {
  SyncService(this._db, this._client, this._connectivity) {
    _connectivitySub = _connectivity.onlineChanges.listen((online) {
      if (online) syncNow();
    });
    _fallbackTimer = Timer.periodic(const Duration(minutes: 2), (_) => syncNow());
  }

  final AppDatabase _db;
  final SupabaseClient _client;
  final ConnectivityService _connectivity;
  StreamSubscription<bool>? _connectivitySub;
  Timer? _fallbackTimer;
  bool _syncing = false;

  void dispose() {
    _connectivitySub?.cancel();
    _fallbackTimer?.cancel();
  }

  Future<SyncResult> syncNow() async {
    if (_syncing) return const SyncResult(pushed: 0, failed: 0);
    _syncing = true;
    var pushed = 0;
    var failed = 0;
    try {
      pushed += await _syncAttendance(onFailed: () => failed++);
      pushed += await _syncObservations(onFailed: () => failed++);
      pushed += await _syncDailyReviews(onFailed: () => failed++);
      pushed += await _syncDailyReviewEntries(onFailed: () => failed++);
    } finally {
      _syncing = false;
    }
    return SyncResult(pushed: pushed, failed: failed);
  }

  Future<int> _syncAttendance({required void Function() onFailed}) async {
    var pushed = 0;
    for (final row in await _db.getDirtyAttendance()) {
      try {
        await _client.from('attendance_records').upsert({
          'student_id': row.studentId,
          'date': row.date,
          'half_day': row.halfDay,
          'status': row.status,
          'reason': row.reason,
        }, onConflict: 'student_id,date,half_day');
        await _db.clearAttendanceDirty(row.studentId, row.date, row.halfDay);
        pushed++;
      } catch (_) {
        onFailed();
      }
    }
    return pushed;
  }

  Future<int> _syncObservations({required void Function() onFailed}) async {
    var pushed = 0;
    for (final row in await _db.getDirtyObservations()) {
      try {
        // `id` généré côté client à la création (voir VieDeClasseRepository) :
        // un upsert sur la clé primaire rend ce ré-essai idempotent.
        await _client.from('observations').upsert({
          'id': row.id,
          'class_id': row.classId,
          'date': row.date,
          'occurred_at': row.occurredAt.toIso8601String(),
          'type': row.type,
          'severity': row.severity,
          'body': row.body,
        });
        final studentIds = (jsonDecode(row.studentIdsJson) as List).cast<String>();
        if (studentIds.isNotEmpty) {
          await _client.from('observation_students').upsert(
                studentIds.map((sid) => {'observation_id': row.id, 'student_id': sid}).toList(),
                onConflict: 'observation_id,student_id',
              );
        }
        await _db.clearObservationDirty(row.id);
        pushed++;
      } catch (_) {
        onFailed();
      }
    }
    return pushed;
  }

  Future<int> _syncDailyReviews({required void Function() onFailed}) async {
    var pushed = 0;
    for (final row in await _db.getDirtyDailyReviews()) {
      try {
        // Jamais d'`id` dans ce payload : si un bilan existe déjà côté
        // serveur pour ce jour (créé par Sandra ou l'autre enseignante lors
        // d'une session précédente), l'upsert sur `day_id` doit modifier ses
        // colonnes SANS toucher à son id — sinon les lignes de
        // `daily_review_entries` qui le référencent déjà se retrouveraient
        // orphelines (pas de `on update cascade` sur cette clé étrangère).
        await _client.from('daily_reviews').upsert(
          {'day_id': row.dayId, 'general_notes': row.generalNotes},
          onConflict: 'day_id',
        );
        await _db.clearDailyReviewDirty(row.dayId);
        pushed++;
      } catch (_) {
        onFailed();
      }
    }
    return pushed;
  }

  Future<int> _syncDailyReviewEntries({required void Function() onFailed}) async {
    var pushed = 0;
    for (final row in await _db.getDirtyDailyReviewEntries()) {
      try {
        // A besoin de l'id serveur du bilan, jamais stocké en local (voir
        // ci-dessus) : une lecture avant écriture, bon marché (indexée sur
        // `day_id`, unique). Échoue proprement si le bilan parent n'est pas
        // encore synchronisé — cette ligne restera dirty pour le prochain
        // passage, une fois `_syncDailyReviews` passé devant.
        final reviewRow =
            await _client.from('daily_reviews').select('id').eq('day_id', row.dayId).single();
        final reviewId = reviewRow['id'] as String;
        await _client.from('daily_review_entries').upsert({
          'daily_review_id': reviewId,
          'journal_entry_id': row.journalEntryId,
          'status': row.status,
          'notes': row.notes,
        }, onConflict: 'daily_review_id,journal_entry_id');
        await _db.clearDailyReviewEntryDirty(row.dayId, row.journalEntryId);
        pushed++;
      } catch (_) {
        onFailed();
      }
    }
    return pushed;
  }
}
