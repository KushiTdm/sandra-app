import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_bootstrap.dart';
import '../../../data/repositories/edt_repository.dart';
import '../../../data/repositories/exercises_repository.dart';
import '../journal_providers.dart';

final exercisesRepositoryProvider =
    Provider<ExercisesRepository>((ref) => ExercisesRepository(supabase));

/// Les fiches déjà validées pour une séance. `autoDispose` : la liste n'est
/// consultée que depuis la séance ouverte.
final sheetsForEntryProvider =
    FutureProvider.autoDispose.family<List<ExerciseSheet>, String>((ref, entryId) {
  return ref.watch(exercisesRepositoryProvider).sheetsForEntry(entryId);
});

/// Les domaines déjà rattachés à l'EDT de la classe, pour le sélecteur de
/// matière de la génération autonome (Sandra choisit la matière elle-même,
/// sans passer par une séance déjà saisie).
final exercisesDomainsProvider = FutureProvider.autoDispose<List<CurriculumDomain>>((ref) async {
  final classId = await ref.watch(journalClassIdProvider.future);
  return EdtRepository(supabase).knownDomains(classId);
});
