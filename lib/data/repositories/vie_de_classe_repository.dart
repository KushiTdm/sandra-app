import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../models/student.dart';
import '../local/app_database.dart';
import '../local/connectivity_service.dart';

const _uuid = Uuid();

class AttendanceRecord {
  const AttendanceRecord({
    required this.studentId,
    required this.halfDay,
    required this.status,
    this.reason,
  });

  final String studentId;
  final String halfDay;
  final String status;
  final String? reason;
}

class Observation {
  const Observation({
    required this.id,
    required this.date,
    required this.type,
    required this.severity,
    this.body,
    required this.studentIds,
    required this.createdAt,
  });

  final String id;
  final DateTime date;
  final String type;
  final int severity;
  final String? body;
  final List<String> studentIds;
  final DateTime createdAt;
}

class DailyReview {
  const DailyReview({this.id, this.generalNotes});
  final String? id;
  final String? generalNotes;
}

class DailyReviewEntry {
  const DailyReviewEntry({required this.journalEntryId, required this.status, this.notes});
  final String journalEntryId;
  final String status;
  final String? notes;
}

/// Appel, signalements et bilan du soir (§6.3, §9.8, Lot 4). Hors ligne
/// d'abord : chaque écriture atterrit immédiatement dans la base locale
/// (`AppDatabase`), avant même de savoir si le réseau répond — Sandra n'est
/// donc jamais bloquée par une coupure wifi de la classe ou de la cour.
/// Une synchronisation immédiate est tentée si possible ; sinon `SyncService`
/// la reprendra dès que la connexion revient. Les remarques du bilan du soir
/// alimentent le contexte de génération IA une fois synchronisées
/// (`daily_reviews.general_notes`, lu par `build_generation_context` /
/// `build_lesson_context`).
class VieDeClasseRepository {
  const VieDeClasseRepository(this._client, this._db, this._connectivity);

  final SupabaseClient _client;
  final AppDatabase _db;
  final ConnectivityService _connectivity;

  static String isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// `connectivity_plus` peut se tromper (wifi sans sortie internet) : en cas
  /// de doute sur l'état lui-même, on préfère tenter l'appel réseau plutôt
  /// que de se priver à tort d'une synchronisation possible.
  Future<bool> get _online async {
    try {
      return await _connectivity.isOnline;
    } catch (_) {
      return true;
    }
  }

  // --- Élèves (trombinoscope mis en cache pour l'appel/le signalement) -----

  Future<List<Student>> students() async {
    if (await _online) {
      try {
        final rows = await _client.from('students').select().eq('is_active', true).order('display_name');
        await _db.replaceStudents(rows
            .map((r) => LocalStudentsCompanion.insert(
                  id: r['id'] as String,
                  lastName: r['last_name'] as String,
                  firstName: r['first_name'] as String,
                  displayName: r['display_name'] as String,
                  pseudoCode: r['pseudo_code'] as String,
                  groupLabel: Value(r['group_label'] as String?),
                  firstLanguage: Value(r['first_language'] as String?),
                  flscoLevel: Value(r['flsco_level'] as int?),
                  notes: Value(r['notes'] as String?),
                  isActive: Value(r['is_active'] as bool? ?? true),
                ))
            .toList());
      } catch (_) {
        // Réseau annoncé mais indisponible en pratique : le cache local
        // ci-dessous prend le relais.
      }
    }
    final local = await _db.getActiveStudents();
    return local
        .map((r) => Student(
              id: r.id,
              lastName: r.lastName,
              firstName: r.firstName,
              displayName: r.displayName,
              pseudoCode: r.pseudoCode,
              groupLabel: r.groupLabel,
              firstLanguage: r.firstLanguage,
              flscoLevel: r.flscoLevel,
              notes: r.notes,
              isActive: r.isActive,
            ))
        .toList();
  }

  // --- Appel -----------------------------------------------------------

  Future<List<AttendanceRecord>> attendanceFor(DateTime date, String halfDay) async {
    final iso = isoDate(date);
    if (await _online) {
      try {
        final rows = await _client
            .from('attendance_records')
            .select('student_id, half_day, status, reason')
            .eq('date', iso)
            .eq('half_day', halfDay);
        await _db.upsertAttendanceFromRemote(rows
            .map((r) => LocalAttendanceCompanion.insert(
                  studentId: r['student_id'] as String,
                  date: iso,
                  halfDay: halfDay,
                  status: r['status'] as String,
                  reason: Value(r['reason'] as String?),
                  updatedAt: DateTime.now(),
                ))
            .toList());
      } catch (_) {
        // lecture hors ligne : le cache local ci-dessous fait foi.
      }
    }
    final local = await _db.getAttendance(iso, halfDay);
    return local
        .map((r) => AttendanceRecord(studentId: r.studentId, halfDay: r.halfDay, status: r.status, reason: r.reason))
        .toList();
  }

  /// Enregistre l'appel pour une demi-journée : toute la classe de
  /// [allStudentIds] sans statut explicite dans [exceptions] est marquée
  /// présente — un seul geste couvre toute la classe. Écrit d'abord en
  /// local (toujours instantané), tente ensuite une synchronisation
  /// immédiate. Renvoie `true` si la synchronisation a réussi tout de suite,
  /// `false` si elle reste en attente (déjà enregistré sans risque de perte).
  Future<bool> saveAttendance({
    required DateTime date,
    required String halfDay,
    required List<String> allStudentIds,
    required Map<String, ({String status, String? reason})> exceptions,
  }) async {
    final iso = isoDate(date);
    final now = DateTime.now();
    final rows = allStudentIds.map((studentId) {
      final exception = exceptions[studentId];
      return LocalAttendanceCompanion.insert(
        studentId: studentId,
        date: iso,
        halfDay: halfDay,
        status: exception?.status ?? 'present',
        reason: Value(exception?.reason),
        dirty: const Value(true),
        updatedAt: now,
      );
    }).toList();

    await _db.writeAttendanceLocally(rows);

    if (await _online) {
      try {
        await _client.from('attendance_records').upsert(
              allStudentIds.map((studentId) {
                final exception = exceptions[studentId];
                return {
                  'student_id': studentId,
                  'date': iso,
                  'half_day': halfDay,
                  'status': exception?.status ?? 'present',
                  'reason': exception?.reason,
                };
              }).toList(),
              onConflict: 'student_id,date,half_day',
            );
        for (final studentId in allStudentIds) {
          await _db.clearAttendanceDirty(studentId, iso, halfDay);
        }
        return true;
      } catch (_) {
        // Reste en attente : SyncService réessaiera. L'appel est déjà
        // enregistré localement, jamais perdu.
      }
    }
    return false;
  }

  // --- Signalements / observations --------------------------------------

  /// Voir [saveAttendance] : local d'abord, synchronisation immédiate en
  /// best-effort, `SyncService` reprend si besoin.
  Future<bool> createObservation({
    required String classId,
    required DateTime date,
    required String type,
    required int severity,
    String? body,
    required List<String> studentIds,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    await _db.insertObservationLocally(LocalObservationsCompanion.insert(
      id: id,
      classId: classId,
      date: isoDate(date),
      occurredAt: now,
      type: type,
      severity: severity,
      body: Value(body),
      studentIdsJson: jsonEncode(studentIds),
      dirty: const Value(true),
      createdAt: now,
    ));

    if (await _online) {
      try {
        await _client.from('observations').upsert({
          'id': id,
          'class_id': classId,
          'date': isoDate(date),
          'occurred_at': now.toIso8601String(),
          'type': type,
          'severity': severity,
          'body': body,
        });
        if (studentIds.isNotEmpty) {
          await _client.from('observation_students').upsert(
                studentIds.map((sid) => {'observation_id': id, 'student_id': sid}).toList(),
                onConflict: 'observation_id,student_id',
              );
        }
        await _db.clearObservationDirty(id);
        return true;
      } catch (_) {
        // idem : reste en attente.
      }
    }
    return false;
  }

  /// Observations concernant un élève donné, les plus récentes d'abord.
  Future<List<Observation>> observationsForStudent(String studentId, {int limit = 30}) async {
    if (await _online) {
      try {
        final rows = await _client
            .from('observation_students')
            .select('observations!inner(id, class_id, date, occurred_at, type, severity, body, created_at)')
            .eq('student_id', studentId)
            .order('date', referencedTable: 'observations', ascending: false)
            .limit(limit);
        await _cacheObservationRows(
          rows.map((r) => r['observations'] as Map<String, dynamic>),
          fallbackStudentIds: [studentId],
        );
      } catch (_) {
        // cache local ci-dessous.
      }
    }
    final local = await _db.getAllObservations();
    final matching = local.where((o) => (jsonDecode(o.studentIdsJson) as List).contains(studentId)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return matching.take(limit).map(_toObservation).toList();
  }

  /// Observations de toute la classe pour une date, avec les élèves concernés.
  Future<List<Observation>> observationsForDate(DateTime date) async {
    final iso = isoDate(date);
    if (await _online) {
      try {
        final rows = await _client
            .from('observations')
            .select('id, class_id, date, occurred_at, type, severity, body, created_at, observation_students(student_id)')
            .eq('date', iso)
            .order('created_at', ascending: false);
        await _cacheObservationRows(rows, studentIdsField: 'observation_students');
      } catch (_) {
        // cache local ci-dessous.
      }
    }
    final local = await _db.getAllObservations();
    final matching = local.where((o) => o.date == iso).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return matching.map(_toObservation).toList();
  }

  Future<void> _cacheObservationRows(
    Iterable<Map<String, dynamic>> rows, {
    String? studentIdsField,
    List<String>? fallbackStudentIds,
  }) async {
    final companions = rows.map((o) {
      final List<String> studentIds;
      if (studentIdsField != null) {
        studentIds =
            (o[studentIdsField] as List).cast<Map<String, dynamic>>().map((l) => l['student_id'] as String).toList();
      } else {
        studentIds = fallbackStudentIds ?? const [];
      }
      return LocalObservationsCompanion.insert(
        id: o['id'] as String,
        classId: o['class_id'] as String,
        date: o['date'] as String,
        occurredAt: DateTime.parse(o['created_at'] as String),
        type: o['type'] as String,
        severity: o['severity'] as int,
        body: Value(o['body'] as String?),
        studentIdsJson: jsonEncode(studentIds),
        createdAt: DateTime.parse(o['created_at'] as String),
      );
    }).toList();
    await _db.upsertObservationsFromRemote(companions);
  }

  Observation _toObservation(LocalObservationRow o) => Observation(
        id: o.id,
        date: DateTime.parse(o.date),
        type: o.type,
        severity: o.severity,
        body: o.body,
        studentIds: (jsonDecode(o.studentIdsJson) as List).cast<String>(),
        createdAt: o.createdAt,
      );

  // --- Bilan du soir -----------------------------------------------------

  Future<DailyReview> loadDailyReview(String dayId) async {
    if (await _online) {
      try {
        final rows = await _client.from('daily_reviews').select('id, general_notes').eq('day_id', dayId).limit(1);
        if (rows.isNotEmpty) {
          await _db.upsertDailyReviewFromRemote(LocalDailyReviewsCompanion.insert(
            dayId: dayId,
            generalNotes: Value(rows.first['general_notes'] as String?),
            updatedAt: DateTime.now(),
          ));
        }
      } catch (_) {
        // cache local ci-dessous.
      }
    }
    final local = await _db.getDailyReview(dayId);
    if (local == null) return const DailyReview();
    return DailyReview(id: dayId, generalNotes: local.generalNotes);
  }

  /// Statuts/notes déjà enregistrés pour les séances d'un jour. Indexé par
  /// `dayId` (pas par l'id serveur du bilan, jamais gardé localement — voir
  /// `SyncService`).
  Future<List<DailyReviewEntry>> loadDailyReviewEntries(String dayId) async {
    final local = await _db.getDailyReviewEntries(dayId);
    return local
        .map((r) => DailyReviewEntry(journalEntryId: r.journalEntryId, status: r.status, notes: r.notes))
        .toList();
  }

  /// Voir [saveAttendance] : local d'abord, synchronisation immédiate en
  /// best-effort. Les entrées sont réécrites par upsert (jamais de
  /// suppression puis réinsertion) : rejouable sans perte si une
  /// synchronisation s'interrompt en plein milieu.
  Future<bool> saveDailyReview({
    required String dayId,
    required String? generalNotes,
    required List<DailyReviewEntry> entries,
  }) async {
    final now = DateTime.now();
    await _db.writeDailyReviewLocally(LocalDailyReviewsCompanion.insert(
      dayId: dayId,
      generalNotes: Value(generalNotes),
      dirty: const Value(true),
      updatedAt: now,
    ));
    await _db.replaceDailyReviewEntriesLocally(
      dayId,
      entries
          .map((e) => LocalDailyReviewEntriesCompanion.insert(
                dayId: dayId,
                journalEntryId: e.journalEntryId,
                status: e.status,
                notes: Value(e.notes),
                dirty: const Value(true),
              ))
          .toList(),
    );

    if (await _online) {
      try {
        // Jamais d'`id` envoyé ici : voir le commentaire équivalent dans
        // SyncService._syncDailyReviews (protège daily_review_entries d'une
        // clé étrangère orpheline).
        await _client.from('daily_reviews').upsert(
          {'day_id': dayId, 'general_notes': generalNotes},
          onConflict: 'day_id',
        );
        await _db.clearDailyReviewDirty(dayId);

        if (entries.isNotEmpty) {
          final reviewRow = await _client.from('daily_reviews').select('id').eq('day_id', dayId).single();
          final reviewId = reviewRow['id'] as String;
          await _client.from('daily_review_entries').upsert(
                entries
                    .map((e) => {
                          'daily_review_id': reviewId,
                          'journal_entry_id': e.journalEntryId,
                          'status': e.status,
                          'notes': e.notes,
                        })
                    .toList(),
                onConflict: 'daily_review_id,journal_entry_id',
              );
          for (final e in entries) {
            await _db.clearDailyReviewEntryDirty(dayId, e.journalEntryId);
          }
        }
        return true;
      } catch (_) {
        // Reste en attente : SyncService réessaiera.
      }
    }
    return false;
  }
}
