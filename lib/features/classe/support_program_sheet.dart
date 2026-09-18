import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/result/result.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/repositories/support_programs_repository.dart';
import 'vie_de_classe_providers.dart';

/// Liste des élèves d'un dispositif (APC ou REF) avec ajout/retrait par
/// simple case à cocher (Sandra, 18 septembre 2026). Écriture directe et
/// immédiate : contrairement à l'appel ou au signalement, cocher un élève
/// ici n'est jamais un geste à faire en urgence sans réseau.
Future<void> showSupportProgramSheet(BuildContext context, SupportProgram program) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _SupportProgramSheet(program: program),
  );
}

class _SupportProgramSheet extends ConsumerWidget {
  const _SupportProgramSheet({required this.program});

  final SupportProgram program;

  Future<void> _toggle(BuildContext context, WidgetRef ref, SupportProgramStudent student) async {
    try {
      await ref.read(supportProgramsRepositoryProvider).setMembership(student.id, program, !student.inProgram);
      ref.invalidate(studentsForProgramProvider(program));
    } on AppException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Échec : ${e.message}')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final students = ref.watch(studentsForProgramProvider(program));

    // Voir AppSpacing.bottomNavClearance : feuille modale ouverte depuis un
    // onglet, donc affichée derrière la barre de navigation flottante.
    return Padding(
      padding: EdgeInsets.only(
        top: 4,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.bottomNavClearance,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 2),
              child: Text(program.fullLabel, style: theme.textTheme.titleLarge),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text('Cochez les élèves qui suivent ce dispositif.', style: theme.textTheme.bodySmall),
            ),
            Flexible(
              child: students.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('Erreur : $e', style: TextStyle(color: theme.colorScheme.error)),
                ),
                data: (list) {
                  final inProgram = list.where((s) => s.inProgram).toList();
                  final others = list.where((s) => !s.inProgram).toList();
                  return ListView(
                    shrinkWrap: true,
                    children: [
                      _SectionHeader('En ${program.shortLabel} (${inProgram.length})'),
                      if (inProgram.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          child: Text('Aucun élève pour le moment.', style: theme.textTheme.bodySmall),
                        ),
                      for (final s in inProgram)
                        _StudentRow(student: s, onToggle: () => _toggle(context, ref, s)),
                      if (others.isNotEmpty) ...[
                        _SectionHeader('Ajouter un élève'),
                        for (final s in others)
                          _StudentRow(student: s, onToggle: () => _toggle(context, ref, s)),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
        child: Text(label, style: Theme.of(context).textTheme.labelLarge),
      );
}

class _StudentRow extends StatelessWidget {
  const _StudentRow({required this.student, required this.onToggle});

  final SupportProgramStudent student;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: student.inProgram,
      onChanged: (_) => onToggle(),
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(student.displayName),
    );
  }
}
