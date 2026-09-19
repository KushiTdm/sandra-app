import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/result/result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../data/repositories/exercises_repository.dart';
import '../../../models/journal_entry.dart';
import '../journal_providers.dart';
import 'exercices_generation_sheet.dart';
import 'exercices_pdf_export.dart';
import 'exercices_providers.dart';

/// Affiche une fiche d'exercices enregistrée, avec le bouton d'impression et
/// — la fiche ayant un `id` (donc déjà en base) — la possibilité de changer
/// le jour visé, la séance liée, et de noter un bilan d'utilisation.
Future<void> showExerciceSheetView(
  BuildContext context, {
  required ExerciseSheet sheet,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _ExerciceSheetView(sheet: sheet),
  );
}

/// Ouvre la fiche en plein écran (Sandra, 16 septembre 2026 : « ajouter la
/// possibilité de mettre en plein écran pour voir de manière optimale ») :
/// une page entière plutôt qu'une feuille contrainte à 85 % de l'écran,
/// utile pour relire les deux niveaux d'une fiche sans avoir à faire défiler
/// une petite fenêtre.
void openExerciceSheetFullscreen(BuildContext context, ExerciseSheet sheet) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (context) => Scaffold(
      appBar: AppBar(title: Text(sheet.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, AppSpacing.bottomNavClearance),
        child: ExerciceSheetBody(sheet: sheet, showAttendu: true),
      ),
    ),
  ));
}

/// `HH:MM` à partir d'un `time` Postgres (`HH:MM:SS`) — chaîne vide si
/// absent plutôt qu'une exception sur une valeur inattendue.
String _timeLabel(String? time) => (time != null && time.length >= 5) ? time.substring(0, 5) : '';

class _ExerciceSheetView extends ConsumerStatefulWidget {
  const _ExerciceSheetView({required this.sheet});

  final ExerciseSheet sheet;

  @override
  ConsumerState<_ExerciceSheetView> createState() => _ExerciceSheetViewState();
}

class _ExerciceSheetViewState extends ConsumerState<_ExerciceSheetView> {
  late ExerciseSheet _sheet = widget.sheet;

  /// Une fiche en relecture avant validation (`id` vide) n'a ni jour figé ni
  /// bilan possible : les deux n'ont de sens qu'une fois la fiche enregistrée.
  bool get _isSaved => _sheet.id.isNotEmpty;

  Future<void> _editSchedule() async {
    final result = await showDialog<({DateTime date, String? entryId})>(
      context: context,
      builder: (context) => _ScheduleEditDialog(
        initialDate: _sheet.date,
        initialEntryId: _sheet.entryId,
      ),
    );
    if (result == null) return;

    final oldEntryId = _sheet.entryId;
    try {
      await ref.read(exercisesRepositoryProvider).updateSchedule(
            _sheet.id,
            date: result.date,
            entryId: result.entryId,
            unlinkEntry: result.entryId == null,
          );
      if (!mounted) return;
      setState(() => _sheet = _sheet.copyWith(date: result.date, entryId: result.entryId));
      if (oldEntryId != null) ref.invalidate(sheetsForEntryProvider(oldEntryId));
      if (_sheet.entryId != null) ref.invalidate(sheetsForEntryProvider(_sheet.entryId!));
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Échec : ${e.message}')));
    }
  }

  Future<void> _editBilan() async {
    final notes = await showDialog<String>(
      context: context,
      builder: (context) => _BilanEditDialog(initialNotes: _sheet.bilanNotes),
    );
    if (notes == null) return;

    try {
      await ref.read(exercisesRepositoryProvider).saveBilan(_sheet.id, notes);
      if (!mounted) return;
      final trimmed = notes.trim();
      setState(() => _sheet = _sheet.copyWith(
            bilanNotes: trimmed.isEmpty ? null : trimmed,
            bilanAt: trimmed.isEmpty ? null : DateTime.now(),
          ));
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Échec : ${e.message}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Voir AppSpacing.bottomNavClearance : feuille modale ouverte depuis un
    // onglet, donc affichée derrière la barre de navigation flottante.
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, AppSpacing.bottomNavClearance),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  tooltip: 'Plein écran',
                  icon: const Icon(Icons.open_in_full),
                  onPressed: () => openExerciceSheetFullscreen(context, _sheet),
                ),
              ),
              ExerciceSheetBody(sheet: _sheet, showAttendu: true),
              if (_isSaved) ...[
                const SizedBox(height: 12),
                _ScheduleSection(sheet: _sheet, onEdit: _editSchedule),
                const SizedBox(height: 12),
                _BilanSection(sheet: _sheet, onEdit: _editBilan),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => exportExercicesToPdf(context, sheet: _sheet),
                  icon: const Icon(Icons.print_outlined),
                  label: const Text('Imprimer / partager en PDF'),
                ),
              ),
              if (_isSaved) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => showExercicePhotoUpdateSheet(context, sheet: _sheet),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Corriger par photo'),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'Le PDF contient une page par niveau pour les élèves, puis une '
                'page de correction pour vous.',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Jour visé et séance liée, avec libellé lisible de la séance (heure +
/// matière/titre) quand il y en a une — pas seulement « liée » sans détail.
class _ScheduleSection extends ConsumerWidget {
  const _ScheduleSection({required this.sheet, required this.onEdit});

  final ExerciseSheet sheet;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    var linkLabel = 'Non liée à une séance';
    if (sheet.entryId != null) {
      final dayState = ref.watch(dayJournalProvider(sheet.date));
      JournalEntry? entry;
      for (final e in dayState.value?.entries ?? const <JournalEntry>[]) {
        if (e.id == sheet.entryId) {
          entry = e;
          break;
        }
      }
      linkLabel = entry != null
          ? 'Liée à ${_timeLabel(entry.startTime)} — '
              '${entry.title?.isNotEmpty == true ? entry.title! : entry.subjectLabel}'
          : 'Liée à une séance de ce jour';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_outlined, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE d MMMM', 'fr_FR').format(sheet.date),
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(linkLabel, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          TextButton(onPressed: onEdit, child: const Text('Modifier')),
        ],
      ),
    );
  }
}

/// Comment l'exercice s'est déroulé pour les élèves — écrit par Sandra après
/// usage, jamais par l'IA (R1 ne s'applique pas : c'est une note personnelle
/// sur une fiche déjà à elle, pas un contenu proposé).
class _BilanSection extends StatelessWidget {
  const _BilanSection({required this.sheet, required this.onEdit});

  final ExerciseSheet sheet;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasBilan = sheet.bilanNotes != null && sheet.bilanNotes!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rate_review_outlined, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text('Bilan', style: theme.textTheme.labelLarge)),
              TextButton(onPressed: onEdit, child: Text(hasBilan ? 'Modifier' : 'Ajouter')),
            ],
          ),
          if (hasBilan) ...[
            const SizedBox(height: 4),
            Text(sheet.bilanNotes!, style: theme.textTheme.bodyMedium),
            if (sheet.bilanAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Noté le ${DateFormat('d MMMM à HH:mm', 'fr_FR').format(sheet.bilanAt!)}',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
              ),
            ],
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Comment l\'exercice s\'est-il déroulé pour les élèves ?',
                style: theme.textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}

class _ScheduleEditDialog extends ConsumerStatefulWidget {
  const _ScheduleEditDialog({required this.initialDate, required this.initialEntryId});

  final DateTime initialDate;
  final String? initialEntryId;

  @override
  ConsumerState<_ScheduleEditDialog> createState() => _ScheduleEditDialogState();
}

class _ScheduleEditDialogState extends ConsumerState<_ScheduleEditDialog> {
  late DateTime _date = widget.initialDate;
  late String? _entryId = widget.initialEntryId;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: now.subtract(const Duration(days: 60)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      _date = picked;
      // La séance liée dépend du jour : un autre jour n'a pas ce créneau.
      _entryId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dayState = ref.watch(dayJournalProvider(_date));

    return AlertDialog(
      title: const Text('Jour et séance liée'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_outlined),
            title: Text(DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(_date)),
            trailing: TextButton(onPressed: _pickDate, child: const Text('Changer')),
          ),
          const SizedBox(height: 8),
          dayState.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: LinearProgressIndicator(),
            ),
            error: (e, _) => Text(
              'Erreur : $e',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            data: (state) {
              final entries = state.entries;
              final validEntryId = entries.any((e) => e.id == _entryId) ? _entryId : null;
              return DropdownButtonFormField<String?>(
                initialValue: validEntryId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Lier à une séance (optionnel)'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Aucune séance liée')),
                  for (final e in entries)
                    DropdownMenuItem(
                      value: e.id,
                      child: Text(
                        '${_timeLabel(e.startTime)} — '
                        '${e.title?.isNotEmpty == true ? e.title! : e.subjectLabel}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (v) => setState(() => _entryId = v),
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler')),
        FilledButton(
          onPressed: () => Navigator.of(context).pop((date: _date, entryId: _entryId)),
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

class _BilanEditDialog extends StatefulWidget {
  const _BilanEditDialog({required this.initialNotes});

  final String? initialNotes;

  @override
  State<_BilanEditDialog> createState() => _BilanEditDialogState();
}

class _BilanEditDialogState extends State<_BilanEditDialog> {
  late final _controller = TextEditingController(text: widget.initialNotes ?? '');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bilan de l\'exercice'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 5,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          hintText: 'Ce qui a bien fonctionné, ce qui a posé difficulté, un '
              'groupe ou une notion à revoir…',
          border: OutlineInputBorder(),
          alignLabelWithHint: true,
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler')),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

/// Corps commun à la relecture (avant validation) et à la consultation
/// (après) : le même rendu dans les deux cas, pour que Sandra valide
/// exactement ce qu'elle verra ensuite.
class ExerciceSheetBody extends StatelessWidget {
  const ExerciceSheetBody({
    super.key,
    required this.sheet,
    this.showAttendu = false,
  });

  final ExerciseSheet sheet;

  /// Les réponses attendues : utiles à l'écran et sur la page de correction,
  /// jamais sur la feuille des élèves.
  final bool showAttendu;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(sheet.title, style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          '${sheet.subjectLabel} · ${DateFormat('EEEE d MMMM', 'fr_FR').format(sheet.date)}'
          '${sheet.dureeMin > 0 ? ' · ${sheet.dureeMin} min' : ''}',
          style: theme.textTheme.bodySmall,
        ),
        if (sheet.objectif.isNotEmpty) ...[
          const SizedBox(height: 12),
          _Label('Objectif'),
          Text(sheet.objectif, style: theme.textTheme.bodyMedium),
        ],
        if (sheet.competenceBo.isNotEmpty) ...[
          const SizedBox(height: 8),
          _Label('Compétence'),
          Text(sheet.competenceBo, style: theme.textTheme.bodySmall),
        ],
        if (sheet.consigneGenerale.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(sheet.consigneGenerale, style: theme.textTheme.bodyMedium),
          ),
        ],
        for (final niveau in sheet.niveaux) ...[
          const SizedBox(height: 20),
          _NiveauBlock(niveau: niveau, showAttendu: showAttendu),
        ],
        if (sheet.materiel.isNotEmpty) ...[
          const SizedBox(height: 16),
          _Label('Matériel'),
          Text(sheet.materiel.join(', '), style: theme.textTheme.bodySmall),
        ],
      ],
    );
  }
}

class _NiveauBlock extends StatelessWidget {
  const _NiveauBlock({required this.niveau, required this.showAttendu});

  final NiveauFiche niveau;
  final bool showAttendu;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEtayage = niveau.niveau == 'etayage';
    final couleur = isEtayage ? AppColors.accent : AppColors.aiProposed;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: couleur.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isEtayage ? Icons.support_outlined : Icons.directions_walk_outlined,
                size: 18,
                color: couleur,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${niveau.label} — ${niveau.titre}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: couleur,
                  ),
                ),
              ),
            ],
          ),
          if (niveau.aides.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final aide in niveau.aides)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text('↳ $aide', style: theme.textTheme.bodySmall),
              ),
          ],
          for (final ex in niveau.exercices) ...[
            const SizedBox(height: 12),
            Text(
              '${ex.numero}. ${ex.consigne}',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            if (ex.items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final item in ex.items)
                      Text('• $item', style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            if (ex.isProduction)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 14),
                child: Text(
                  '(l\'élève écrit — lignes prévues sur la fiche imprimée)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            if (showAttendu && ex.attendu.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 14),
                child: Text(
                  'Attendu : ${ex.attendu}',
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.masteryAcquis),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
              letterSpacing: 0.6,
            ),
      );
}
