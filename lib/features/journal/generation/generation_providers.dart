import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_bootstrap.dart';
import '../../../data/repositories/generation_repository.dart';
import '../../classe/vie_de_classe_providers.dart';

final generationRepositoryProvider = Provider<GenerationRepository>((ref) => GenerationRepository(supabase));

/// Une génération de cahier journal (jour ou semaine) déjà en cours pour
/// cette classe et pas encore terminée, s'il y en a une — proposée en
/// reprise à l'ouverture de l'écran (§9.6 : l'état vit en base, pas dans le
/// téléphone).
final resumableGenerationProvider = FutureProvider.autoDispose.family<GenerationRequest?, String>((ref, classId) {
  return ref.watch(generationRepositoryProvider).findResumableRequest(classId);
});

/// Trombinoscope pour afficher de vrais prénoms plutôt que des codes E01…E24
/// dans les écrans de génération (contexte, squelette) — les codes eux-mêmes
/// ne quittent jamais l'app (R2), cette table ne sert qu'à l'affichage.
final studentDisplayNamesProvider = FutureProvider.autoDispose<Map<String, String>>((ref) async {
  final students = await ref.watch(studentsProvider.future);
  return {for (final s in students) s.pseudoCode: s.displayName};
});
