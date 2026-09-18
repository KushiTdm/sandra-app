import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/supabase/supabase_bootstrap.dart';
import '../../data/local/app_database.dart';
import '../../data/local/connectivity_service.dart';
import '../../data/local/sync_service.dart';
import '../../data/repositories/support_programs_repository.dart';
import '../../data/repositories/vie_de_classe_repository.dart';
import '../../models/student.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) => ConnectivityService(Connectivity()));

/// Instancié une seule fois pour toute l'app (voir `CahierJournalApp`, qui le
/// lit dès le démarrage) : c'est ce qui fait tourner en permanence l'écoute
/// de connectivité et le minuteur de repli, pas seulement quand un écran
/// Classe est ouvert.
final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(
    ref.watch(appDatabaseProvider),
    supabase,
    ref.watch(connectivityServiceProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

/// Nombre d'éléments (appel/signalement/bilan) écrits localement et pas
/// encore confirmés côté serveur — alimente le bandeau de statut (§3.5).
final pendingSyncCountProvider = StreamProvider<int>((ref) {
  return ref.watch(appDatabaseProvider).watchPendingCount();
});

final isOnlineProvider = StreamProvider<bool>((ref) async* {
  final connectivity = ref.watch(connectivityServiceProvider);
  yield await connectivity.isOnline;
  yield* connectivity.onlineChanges;
});

final vieDeClasseRepositoryProvider = Provider<VieDeClasseRepository>((ref) {
  return VieDeClasseRepository(
    supabase,
    ref.watch(appDatabaseProvider),
    ref.watch(connectivityServiceProvider),
  );
});

final studentsProvider = FutureProvider.autoDispose<List<Student>>((ref) {
  return ref.watch(vieDeClasseRepositoryProvider).students();
});

final supportProgramsRepositoryProvider = Provider<SupportProgramsRepository>((ref) {
  return SupportProgramsRepository(supabase);
});

final studentsForProgramProvider =
    FutureProvider.autoDispose.family<List<SupportProgramStudent>, SupportProgram>((ref, program) {
  return ref.watch(supportProgramsRepositoryProvider).studentsFor(program);
});

final attendanceForProvider =
    FutureProvider.autoDispose.family<List<AttendanceRecord>, ({DateTime date, String halfDay})>((ref, key) {
  return ref.watch(vieDeClasseRepositoryProvider).attendanceFor(key.date, key.halfDay);
});

final observationsForStudentProvider =
    FutureProvider.autoDispose.family<List<Observation>, String>((ref, studentId) {
  return ref.watch(vieDeClasseRepositoryProvider).observationsForStudent(studentId);
});

/// Après-midi commence à la pause déjeuner (12:45, §3.2) : sert de valeur
/// par défaut pour présélectionner le bon volet de l'appel selon l'heure.
String currentHalfDay() {
  final now = DateTime.now();
  final minutesSinceMidnight = now.hour * 60 + now.minute;
  return minutesSinceMidnight < (12 * 60 + 45) ? 'matin' : 'apres_midi';
}
