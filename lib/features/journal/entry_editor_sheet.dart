import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/result/result.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/repositories/journal_repository.dart';
import '../../models/journal_entry.dart';
import 'journal_providers.dart';

const _statusLabels = {
  'prevue': 'Prévue',
  'faite': 'Faite',
  'partielle': 'Partielle',
  'reportee': 'Reportée',
  'annulee': 'Annulée',
};

/// Éditeur structuré (§8.3) : un champ par élément de la trame, jamais un
/// bloc de texte libre. `initial` nul = création (à partir d'un créneau) ;
/// renseigné = modification d'une séance existante. La journée
/// (`journal_days`) n'est créée qu'au moment de l'enregistrement, jamais
/// avant — voir `JournalRepository.ensureDay`.
Future<bool?> showEntryEditorSheet(
  BuildContext context, {
  required String classId,
  required DateTime date,
  String? slotId,
  String? startTime,
  String? endTime,
  required String subjectLabel,
  String? domainCode,
  String? groupLabel,
  JournalEntry? initial,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _EntryEditorSheet(
      classId: classId,
      date: date,
      slotId: slotId,
      startTime: startTime,
      endTime: endTime,
      subjectLabel: subjectLabel,
      domainCode: domainCode,
      groupLabel: groupLabel,
      initial: initial,
    ),
  );
}

class _EntryEditorSheet extends ConsumerStatefulWidget {
  const _EntryEditorSheet({
    required this.classId,
    required this.date,
    this.slotId,
    this.startTime,
    this.endTime,
    required this.subjectLabel,
    this.domainCode,
    this.groupLabel,
    this.initial,
  });

  final String classId;
  final DateTime date;
  final String? slotId;
  final String? startTime;
  final String? endTime;
  final String subjectLabel;
  final String? domainCode;
  final String? groupLabel;
  final JournalEntry? initial;

  @override
  ConsumerState<_EntryEditorSheet> createState() => _EntryEditorSheetState();
}

class _EntryEditorSheetState extends ConsumerState<_EntryEditorSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _competenceController;
  late final TextEditingController _objectiveController;
  late final TextEditingController _differenciationController;
  late final TextEditingController _newStepController;
  late final TextEditingController _newMaterielController;
  late List<String> _steps;
  late List<String> _materiel;
  late String _status;
  Set<String> _selectedNotions = {};
  bool _saving = false;
  bool _loadingNotions = true;
  String? _error;
  List<NotionOption> _availableNotions = [];

  @override
  void initState() {
    super.initState();
    final e = widget.initial;
    _titleController = TextEditingController(text: e?.title ?? '');
    _competenceController = TextEditingController(text: e?.competenceBo ?? '');
    _objectiveController = TextEditingController(text: e?.objective ?? '');
    _differenciationController = TextEditingController(text: e?.differenciation ?? '');
    _newStepController = TextEditingController();
    _newMaterielController = TextEditingController();
    _steps = List.of(e?.deroulementSteps ?? const []);
    _materiel = List.of(e?.materiel ?? const []);
    _status = e?.status ?? 'prevue';
    _loadNotions();
  }

  Future<void> _loadNotions() async {
    final domainCode = widget.domainCode;
    if (domainCode == null) {
      setState(() => _loadingNotions = false);
      return;
    }
    final repo = ref.read(journalRepositoryProvider);
    final options = await repo.notionsForDomain(domainCode);
    final selected = widget.initial != null
        ? (await repo.entryNotions(widget.initial!.id)).map((l) => l.notionCode).toSet()
        : <String>{};
    if (!mounted) return;
    setState(() {
      _availableNotions = options;
      _selectedNotions = selected;
      _loadingNotions = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _competenceController.dispose();
    _objectiveController.dispose();
    _differenciationController.dispose();
    _newStepController.dispose();
    _newMaterielController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final repo = ref.read(journalRepositoryProvider);
    try {
      final JournalEntry entry;
      if (widget.initial == null) {
        final dayId = await repo.ensureDay(widget.classId, widget.date);
        entry = await repo.createEntry(
          dayId: dayId,
          slotId: widget.slotId,
          startTime: widget.startTime,
          endTime: widget.endTime,
          subjectLabel: widget.subjectLabel,
          domainCode: widget.domainCode,
          groupLabel: widget.groupLabel,
          title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
          competenceBo: _competenceController.text.trim().isEmpty ? null : _competenceController.text.trim(),
          objective: _objectiveController.text.trim().isEmpty ? null : _objectiveController.text.trim(),
          steps: _steps,
          differenciation:
              _differenciationController.text.trim().isEmpty ? null : _differenciationController.text.trim(),
          materiel: _materiel,
          status: _status,
        );
      } else {
        entry = await repo.updateEntry(
          widget.initial!.id,
          subjectLabel: widget.subjectLabel,
          domainCode: widget.domainCode,
          groupLabel: widget.groupLabel,
          title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
          competenceBo: _competenceController.text.trim().isEmpty ? null : _competenceController.text.trim(),
          objective: _objectiveController.text.trim().isEmpty ? null : _objectiveController.text.trim(),
          steps: _steps,
          differenciation:
              _differenciationController.text.trim().isEmpty ? null : _differenciationController.text.trim(),
          materiel: _materiel,
          status: _status,
        );
      }

      if (widget.domainCode != null) {
        await repo.setEntryNotions(
          entry.id,
          _selectedNotions.map((c) => EntryNotionLink(notionCode: c, intent: 'entrainement')).toList(),
        );
      }

      if (!mounted) return;
      ref.invalidate(dayJournalProvider(widget.date));
      Navigator.of(context).pop(true);
    } on AppException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Échec de l\'enregistrement : $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final entry = widget.initial;
    if (entry == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cette séance ?'),
        content: Text(entry.title?.isNotEmpty == true ? entry.title! : entry.subjectLabel),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _saving = true);
    try {
      await ref.read(journalRepositoryProvider).deleteEntry(entry.id);
      if (!mounted) return;
      ref.invalidate(dayJournalProvider(widget.date));
      Navigator.of(context).pop(true);
    } on AppException catch (e) {
      setState(() {
        _error = e.message;
        _saving = false;
      });
    }
  }

  void _addStep() {
    final text = _newStepController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _steps.add(text);
      _newStepController.clear();
    });
  }

  void _addMateriel() {
    final text = _newMaterielController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _materiel.add(text);
      _newMaterielController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Voir AppSpacing.bottomNavClearance : feuille modale ouverte depuis un
      // onglet, donc affichée derrière la barre de navigation flottante.
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.bottomNavClearance,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.subjectLabel, style: Theme.of(context).textTheme.titleLarge),
            if (widget.startTime != null)
              Text(
                '${widget.startTime!.substring(0, 5)}–${widget.endTime?.substring(0, 5) ?? ''}'
                '${widget.groupLabel != null ? ' · Groupe ${widget.groupLabel}' : ''}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Intitulé'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _competenceController,
              decoration: const InputDecoration(labelText: 'Compétence (BO)'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _objectiveController,
              decoration: const InputDecoration(labelText: 'Objectif opérationnel'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Text('Déroulement', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            ..._steps.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Text('${e.key + 1}.', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(width: 8),
                      Expanded(child: Text(e.value)),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() => _steps.removeAt(e.key)),
                      ),
                    ],
                  ),
                )),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newStepController,
                    decoration: const InputDecoration(hintText: 'Ajouter une étape…'),
                    onSubmitted: (_) => _addStep(),
                  ),
                ),
                IconButton(icon: const Icon(Icons.add), onPressed: _addStep),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _differenciationController,
              decoration: const InputDecoration(labelText: 'Différenciation'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Text('Matériel', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final item in _materiel)
                  InputChip(
                    label: Text(item),
                    onDeleted: () => setState(() => _materiel.remove(item)),
                  ),
                SizedBox(
                  width: 160,
                  child: TextField(
                    controller: _newMaterielController,
                    decoration: const InputDecoration(hintText: 'Ajouter…', isDense: true),
                    onSubmitted: (_) => _addMateriel(),
                  ),
                ),
              ],
            ),
            if (widget.domainCode != null) ...[
              const SizedBox(height: 16),
              Text('Notions travaillées (${widget.domainCode})', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              if (_loadingNotions)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(),
                )
              else if (_availableNotions.isEmpty)
                const Text('Aucune notion connue pour ce domaine.')
              else
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _availableNotions
                      .map((n) => FilterChip(
                            label: Text(n.code),
                            selected: _selectedNotions.contains(n.code),
                            onSelected: (selected) => setState(() {
                              if (selected) {
                                _selectedNotions.add(n.code);
                              } else {
                                _selectedNotions.remove(n.code);
                              }
                            }),
                          ))
                      .toList(),
                ),
            ],
            const SizedBox(height: 16),
            Text('Statut', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: _statusLabels.entries
                  .map((e) => ChoiceChip(
                        label: Text(e.value),
                        selected: _status == e.key,
                        onSelected: (_) => setState(() => _status = e.key),
                      ))
                  .toList(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                if (widget.initial != null)
                  TextButton(
                    onPressed: _saving ? null : _delete,
                    style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                    child: const Text('Supprimer'),
                  ),
                const Spacer(),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Enregistrer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
