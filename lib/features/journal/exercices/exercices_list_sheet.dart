import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import 'exercice_sheet_view.dart';
import 'exercices_generation_sheet.dart';
import 'exercices_providers.dart';

/// Les fiches d'exercices déjà enregistrées pour une séance. Vide au début —
/// l'écran propose alors directement d'en générer une.
Future<void> showExercicesListSheet(
  BuildContext context, {
  required String entryId,
  required String seanceLabel,
  required DateTime seanceDate,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _ExercicesList(
      entryId: entryId,
      seanceLabel: seanceLabel,
      seanceDate: seanceDate,
    ),
  );
}

class _ExercicesList extends ConsumerWidget {
  const _ExercicesList({required this.entryId, required this.seanceLabel, required this.seanceDate});

  final String entryId;
  final String seanceLabel;
  final DateTime seanceDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sheets = ref.watch(sheetsForEntryProvider(entryId));

    // Voir AppSpacing.bottomNavClearance : feuille modale ouverte depuis un
    // onglet, donc affichée derrière la barre de navigation flottante.
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, AppSpacing.bottomNavClearance),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Fiches d\'exercices', style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(seanceLabel, style: theme.textTheme.bodySmall),
          const SizedBox(height: 16),
          switch (sheets) {
            AsyncError(:final error) => Text(
                'Erreur : $error',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            AsyncData(:final value) when value.isEmpty => Text(
                'Aucune fiche pour cette séance pour le moment.',
                style: theme.textTheme.bodyMedium,
              ),
            AsyncData(:final value) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final sheet in value)
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.assignment_outlined,
                            color: AppColors.aiProposed),
                        title: Text(sheet.title),
                        subtitle: Text(
                          '${sheet.niveaux.length} niveaux · '
                          '${sheet.niveaux.fold<int>(0, (n, niv) => n + niv.exercices.length)} exercices'
                          '${sheet.dureeMin > 0 ? ' · ${sheet.dureeMin} min' : ''}\n'
                          'Enregistrée le ${DateFormat('d MMMM', 'fr_FR').format(sheet.date)}',
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          tooltip: 'Supprimer',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Supprimer cette fiche ?'),
                                content: Text(sheet.title),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Annuler'),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Supprimer'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed != true) return;
                            await ref
                                .read(exercisesRepositoryProvider)
                                .deleteSheet(sheet.id);
                            ref.invalidate(sheetsForEntryProvider(entryId));
                          },
                        ),
                        onTap: () => showExerciceSheetView(context, sheet: sheet),
                      ),
                    ),
                ],
              ),
            _ => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
          },
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                showExercicesGenerationSheet(
                  context,
                  entryId: entryId,
                  seanceLabel: seanceLabel,
                  seanceDate: seanceDate,
                );
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Générer une nouvelle fiche'),
            ),
          ),
        ],
      ),
    );
  }
}
