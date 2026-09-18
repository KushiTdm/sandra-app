import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/result/result.dart';

/// APC (activité pédagogique complémentaire) et REF (renforcement de
/// l'enseignement du français) : deux listes d'élèves que Sandra tient à
/// jour (18 septembre 2026), qu'elle anime elle-même (APC) ou non (REF,
/// encadré par un autre enseignant — elle garde seulement la liste).
enum SupportProgram {
  apc('in_apc', 'APC', 'Activité pédagogique complémentaire'),
  ref('in_ref', 'REF', 'Renforcement de l\'enseignement du français');

  const SupportProgram(this.column, this.shortLabel, this.fullLabel);

  /// Colonne de `students` portant l'appartenance à ce dispositif.
  final String column;
  final String shortLabel;
  final String fullLabel;
}

class SupportProgramStudent {
  const SupportProgramStudent({required this.id, required this.displayName, required this.inProgram});

  final String id;
  final String displayName;
  final bool inProgram;
}

/// Écriture directe (pas de cache hors-ligne, contrairement à
/// `VieDeClasseRepository`) : gérer ces deux listes est un geste
/// occasionnel, jamais requis en pleine séance sans réseau.
class SupportProgramsRepository {
  const SupportProgramsRepository(this._client);

  final SupabaseClient _client;

  Future<List<SupportProgramStudent>> studentsFor(SupportProgram program) async {
    try {
      final rows = await _client
          .from('students')
          .select('id, display_name, ${program.column}')
          .eq('is_active', true)
          .order('display_name');
      return (rows as List)
          .map((r) => SupportProgramStudent(
                id: r['id'] as String,
                displayName: r['display_name'] as String,
                inProgram: r[program.column] as bool? ?? false,
              ))
          .toList();
    } on PostgrestException catch (e) {
      throw AppException(e.message, e);
    }
  }

  Future<void> setMembership(String studentId, SupportProgram program, bool value) async {
    try {
      await _client.from('students').update({program.column: value}).eq('id', studentId);
    } on PostgrestException catch (e) {
      throw AppException(e.message, e);
    }
  }
}
