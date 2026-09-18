import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'app_database.g.dart';

/// Base locale (Lot 4 — saisie hors ligne réelle, §3.5). Ne mirroir que ce
/// dont l'appel/le signalement/le bilan du soir ont besoin pour rester
/// utilisables sans réseau (R1-R8 ne changent pas : cette base ne fait que
/// retarder l'écriture chez Supabase, elle ne contourne aucune RLS — toute
/// synchronisation repasse par le JWT de Sandra, voir `SyncService`).
@DriftDatabase(tables: [
  LocalStudents,
  LocalAttendance,
  LocalObservations,
  LocalDailyReviews,
  LocalDailyReviewEntries,
  LocalMeta,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'cahier_journal_local.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }

  // --- Meta ---------------------------------------------------------------

  Future<String?> getMeta(String key) async {
    final row = await (select(localMeta)..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> setMeta(String key, String value) {
    return into(localMeta).insertOnConflictUpdate(LocalMetaCompanion.insert(key: key, value: value));
  }

  // --- Élèves ---------------------------------------------------------------

  Future<void> replaceStudents(List<LocalStudentsCompanion> rows) {
    return transaction(() async {
      await delete(localStudents).go();
      for (final row in rows) {
        await into(localStudents).insertOnConflictUpdate(row);
      }
    });
  }

  Future<List<LocalStudentRow>> getActiveStudents() {
    return (select(localStudents)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.displayName)]))
        .get();
  }

  // --- Appel ---------------------------------------------------------------

  Future<List<LocalAttendanceRow>> getAttendance(String date, String halfDay) {
    return (select(localAttendance)..where((t) => t.date.equals(date) & t.halfDay.equals(halfDay))).get();
  }

  /// Écrit des lignes venues du serveur, sans jamais écraser une ligne locale
  /// encore `dirty` (une saisie pas encore synchronisée gagne toujours contre
  /// une lecture réseau plus ancienne qu'elle).
  Future<void> upsertAttendanceFromRemote(List<LocalAttendanceCompanion> rows) {
    return transaction(() async {
      for (final row in rows) {
        final existing = await (select(localAttendance)
              ..where((t) =>
                  t.studentId.equals(row.studentId.value) &
                  t.date.equals(row.date.value) &
                  t.halfDay.equals(row.halfDay.value)))
            .getSingleOrNull();
        if (existing != null && existing.dirty) continue;
        await into(localAttendance).insertOnConflictUpdate(row);
      }
    });
  }

  Future<void> writeAttendanceLocally(List<LocalAttendanceCompanion> rows) {
    return batch((b) => b.insertAllOnConflictUpdate(localAttendance, rows));
  }

  Future<List<LocalAttendanceRow>> getDirtyAttendance() {
    return (select(localAttendance)..where((t) => t.dirty.equals(true))).get();
  }

  Future<void> clearAttendanceDirty(String studentId, String date, String halfDay) {
    return (update(localAttendance)
          ..where((t) => t.studentId.equals(studentId) & t.date.equals(date) & t.halfDay.equals(halfDay)))
        .write(const LocalAttendanceCompanion(dirty: Value(false)));
  }

  // --- Signalements ---------------------------------------------------------

  Future<List<LocalObservationRow>> getAllObservations() => select(localObservations).get();

  Future<void> upsertObservationsFromRemote(List<LocalObservationsCompanion> rows) {
    return transaction(() async {
      for (final row in rows) {
        final existing =
            await (select(localObservations)..where((t) => t.id.equals(row.id.value))).getSingleOrNull();
        if (existing != null && existing.dirty) continue;
        await into(localObservations).insertOnConflictUpdate(row);
      }
    });
  }

  Future<void> insertObservationLocally(LocalObservationsCompanion row) {
    return into(localObservations).insertOnConflictUpdate(row);
  }

  Future<List<LocalObservationRow>> getDirtyObservations() {
    return (select(localObservations)..where((t) => t.dirty.equals(true))).get();
  }

  Future<void> clearObservationDirty(String id) {
    return (update(localObservations)..where((t) => t.id.equals(id)))
        .write(const LocalObservationsCompanion(dirty: Value(false)));
  }

  // --- Bilan du soir ---------------------------------------------------------

  Future<LocalDailyReviewRow?> getDailyReview(String dayId) {
    return (select(localDailyReviews)..where((t) => t.dayId.equals(dayId))).getSingleOrNull();
  }

  Future<void> upsertDailyReviewFromRemote(LocalDailyReviewsCompanion row) async {
    final existing = await getDailyReview(row.dayId.value);
    if (existing != null && existing.dirty) return;
    await into(localDailyReviews).insertOnConflictUpdate(row);
  }

  Future<void> writeDailyReviewLocally(LocalDailyReviewsCompanion row) {
    return into(localDailyReviews).insertOnConflictUpdate(row);
  }

  Future<List<LocalDailyReviewRow>> getDirtyDailyReviews() {
    return (select(localDailyReviews)..where((t) => t.dirty.equals(true))).get();
  }

  Future<void> clearDailyReviewDirty(String dayId) {
    return (update(localDailyReviews)..where((t) => t.dayId.equals(dayId)))
        .write(const LocalDailyReviewsCompanion(dirty: Value(false)));
  }

  Future<List<LocalDailyReviewEntryRow>> getDailyReviewEntries(String dayId) {
    return (select(localDailyReviewEntries)..where((t) => t.dayId.equals(dayId))).get();
  }

  Future<void> replaceDailyReviewEntriesLocally(String dayId, List<LocalDailyReviewEntriesCompanion> rows) {
    return batch((b) => b.insertAllOnConflictUpdate(localDailyReviewEntries, rows));
  }

  Future<List<LocalDailyReviewEntryRow>> getDirtyDailyReviewEntries() {
    return (select(localDailyReviewEntries)..where((t) => t.dirty.equals(true))).get();
  }

  Future<void> clearDailyReviewEntryDirty(String dayId, String journalEntryId) {
    return (update(localDailyReviewEntries)
          ..where((t) => t.dayId.equals(dayId) & t.journalEntryId.equals(journalEntryId)))
        .write(const LocalDailyReviewEntriesCompanion(dirty: Value(false)));
  }

  // --- Compteur d'attente, pour le bandeau de statut (§3.5) -----------------

  Stream<int> watchPendingCount() {
    final controller = StreamController<int>.broadcast();
    final counts = <String, int>{'attendance': 0, 'observations': 0, 'reviews': 0, 'entries': 0};
    void emit() => controller.add(counts.values.fold(0, (sum, v) => sum + v));

    final subscriptions = <StreamSubscription<int>>[
      (select(localAttendance)..where((t) => t.dirty.equals(true))).watch().map((r) => r.length).listen((v) {
        counts['attendance'] = v;
        emit();
      }),
      (select(localObservations)..where((t) => t.dirty.equals(true))).watch().map((r) => r.length).listen((v) {
        counts['observations'] = v;
        emit();
      }),
      (select(localDailyReviews)..where((t) => t.dirty.equals(true))).watch().map((r) => r.length).listen((v) {
        counts['reviews'] = v;
        emit();
      }),
      (select(localDailyReviewEntries)..where((t) => t.dirty.equals(true))).watch().map((r) => r.length).listen((v) {
        counts['entries'] = v;
        emit();
      }),
    ];

    controller.onCancel = () async {
      for (final s in subscriptions) {
        await s.cancel();
      }
    };
    return controller.stream;
  }
}
