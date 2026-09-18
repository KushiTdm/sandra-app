import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../models/student.dart';
import 'vie_de_classe_providers.dart';

const _typeLabels = {
  'positif': 'Positif',
  'difficulte': 'Difficulté',
  'comportement': 'Comportement',
  'sante': 'Santé',
  'materiel': 'Matériel',
  'autre': 'Autre',
};

const _severityColors = {
  1: AppColors.masteryEnCours,
  2: AppColors.masteryFragile,
  3: AppColors.masteryNonAcquis,
};

/// Fiche élève (§8, Lot 8) : lecture simple pour l'instant — identité,
/// signalements passés. La maîtrise par notion apparaîtra une fois
/// `student_notion_events` alimenté (Lots 4/8, pas encore le cas).
class FicheEleveScreen extends ConsumerWidget {
  const FicheEleveScreen({super.key, required this.student});

  final Student student;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final observations = ref.watch(observationsForStudentProvider(student.id));

    return Scaffold(
      appBar: AppBar(title: Text(student.displayName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow('Groupe', student.groupLabel ?? '—'),
                  _InfoRow('Langue première', student.firstLanguage ?? '—'),
                  _InfoRow('Niveau FLSco', student.flscoLevel?.toString() ?? '—'),
                  if (student.notes?.isNotEmpty ?? false) _InfoRow('Notes', student.notes!),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Maîtrise du programme', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          const Text(
            'Aucune donnée pour l\'instant — se remplit séance après séance une fois '
            'le suivi de maîtrise en usage (Lot 8).',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Text('Signalements', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          observations.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('Erreur : $e'),
            data: (list) {
              if (list.isEmpty) {
                return const Text('Aucun signalement enregistré.', style: TextStyle(color: Colors.grey));
              }
              return Column(
                children: list.map((o) => Card(
                      margin: const EdgeInsets.only(bottom: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: (_severityColors[o.severity] ?? AppColors.masteryNonVu)
                              .withValues(alpha: 0.2),
                          child: Icon(Icons.flag_outlined, color: _severityColors[o.severity], size: 18),
                        ),
                        title: Text(_typeLabels[o.type] ?? o.type),
                        subtitle: Text([
                          DateFormat('dd/MM/yyyy').format(o.date),
                          if (o.body?.isNotEmpty ?? false) o.body!,
                        ].join(' · ')),
                        isThreeLine: (o.body?.length ?? 0) > 40,
                      ),
                    )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 130, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
