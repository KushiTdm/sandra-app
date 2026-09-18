import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/support_programs_repository.dart';
import '../../models/student.dart';
import 'appel_screen.dart';
import 'fiche_eleve_screen.dart';
import 'support_program_sheet.dart';
import 'vie_de_classe_providers.dart';

class ClasseScreen extends ConsumerWidget {
  const ClasseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final students = ref.watch(studentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Classe'),
        actions: [
          IconButton(
            tooltip: SupportProgram.apc.fullLabel,
            icon: const Icon(Icons.schedule_outlined),
            onPressed: () => showSupportProgramSheet(context, SupportProgram.apc),
          ),
          IconButton(
            tooltip: SupportProgram.ref.fullLabel,
            icon: const Icon(Icons.translate_outlined),
            onPressed: () => showSupportProgramSheet(context, SupportProgram.ref),
          ),
          IconButton(
            tooltip: 'Faire l\'appel',
            icon: const Icon(Icons.fact_check_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AppelScreen()),
            ),
          ),
        ],
      ),
      body: students.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (list) {
          final groupA = list.where((s) => s.groupLabel == 'A').toList();
          final groupB = list.where((s) => s.groupLabel == 'B').toList();
          final others = list.where((s) => s.groupLabel != 'A' && s.groupLabel != 'B').toList();

          return ListView(
            children: [
              if (groupA.isNotEmpty) _GroupHeader('Groupe A (${groupA.length})'),
              ...groupA.map((s) => _StudentTile(student: s)),
              if (groupB.isNotEmpty) _GroupHeader('Groupe B (${groupB.length})'),
              ...groupB.map((s) => _StudentTile(student: s)),
              if (others.isNotEmpty) _GroupHeader('Autres (${others.length})'),
              ...others.map((s) => _StudentTile(student: s)),
            ],
          );
        },
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

class _StudentTile extends StatelessWidget {
  const _StudentTile({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(student.displayName.substring(0, 1))),
      title: Text(student.displayName),
      subtitle: student.firstLanguage != null ? Text(student.firstLanguage!) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => FicheEleveScreen(student: student)),
      ),
    );
  }
}
