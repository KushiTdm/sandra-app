import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/result/result.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/repositories/vie_de_classe_repository.dart';
import '../../models/journal_entry.dart';
import '../journal/journal_providers.dart';
import 'vie_de_classe_providers.dart';

const _statusLabels = {
  'faite': 'Faite',
  'partielle': 'Partielle',
  'reportee': 'Reportée',
  'annulee': 'Annulée',
};

/// Humeur de la classe (docs/prompts/claude_design_prompt.md, écran 12) —
/// prévue en icônes sobres à l'origine ; le rendu généré n'étant pas
/// concluant, on retombe sur des émoticônes, plus lisibles à cette taille.
/// Aucune colonne dédiée en base pour l'instant (pas de migration dans ce
/// lot) : l'humeur est encodée en première ligne de `generalNotes` et
/// re-décodée à la lecture — zéro changement de schéma, 100 % rétrocompatible
/// avec les bilans déjà enregistrés (qui n'ont simplement aucune humeur).
const _moods = [
  ('😌', 'Calme'),
  ('⚡️', 'Dynamique'),
  ('🌪️', 'Agitée'),
  ('😴', 'Fatiguée'),
  ('🤩', 'Enthousiaste'),
];
const _moodPrefix = 'Humeur de la classe : ';

(String?, String) _extractMood(String notes) {
  final firstLine = notes.split('\n').first;
  if (firstLine.startsWith(_moodPrefix)) {
    final emoji = firstLine.substring(_moodPrefix.length).trim();
    final rest = notes
        .substring(firstLine.length)
        .replaceFirst(RegExp(r'^\n+'), '');
    return (emoji, rest);
  }
  return (null, notes);
}

/// Bilan du soir (§6.5, Lot 9) : non obligatoire, proposé à Sandra en fin de
/// journée. Ce qu'elle écrit ici (`daily_reviews.general_notes`) alimente le
/// contexte de génération IA (`build_generation_context`/`build_lesson_context`,
/// bloc "remarques") — l'IA s'améliore avec ce que Sandra en dit vraiment.
class BilanSoirScreen extends ConsumerStatefulWidget {
  const BilanSoirScreen({super.key, required this.classId, required this.date});

  final String classId;
  final DateTime date;

  @override
  ConsumerState<BilanSoirScreen> createState() => _BilanSoirScreenState();
}

class _BilanSoirScreenState extends ConsumerState<BilanSoirScreen> {
  final _notesController = TextEditingController();
  final Map<String, String> _statusOverrides = {};
  final Map<String, TextEditingController> _entryNoteControllers = {};
  bool _loaded = false;
  bool _saving = false;
  String? _selectedMood;

  @override
  void dispose() {
    _notesController.dispose();
    for (final c in _entryNoteControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<(DailyReview, List<DailyReviewEntry>)> _loadReviewAndEntries(
    VieDeClasseRepository repo,
    String dayId,
  ) async {
    final review = await repo.loadDailyReview(dayId);
    final entries = await repo.loadDailyReviewEntries(dayId);
    return (review, entries);
  }

  Future<void> _save(String? dayId, List<JournalEntry> entries) async {
    if (dayId == null) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(vieDeClasseRepositoryProvider);
      final rawNotes = _notesController.text.trim();
      final notesWithMood = _selectedMood == null
          ? rawNotes
          : '$_moodPrefix$_selectedMood${rawNotes.isEmpty ? '' : '\n\n$rawNotes'}';
      final synced = await repo.saveDailyReview(
        dayId: dayId,
        generalNotes: notesWithMood.isEmpty ? null : notesWithMood,
        entries: entries.map((e) {
          final status = _statusOverrides[e.id] ?? e.status;
          final notes = _entryNoteControllers[e.id]?.text.trim();
          return DailyReviewEntry(
            journalEntryId: e.id,
            status: status,
            notes: (notes?.isEmpty ?? true) ? null : notes,
          );
        }).toList(),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            synced
                ? 'Bilan du soir enregistré.'
                : 'Bilan du soir enregistré (en attente de réseau).',
          ),
        ),
      );
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Échec : ${e.message}')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final journal = ref.watch(dayJournalProvider(widget.date));
    final repo = ref.watch(vieDeClasseRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Bilan du ${DateFormat('dd/MM/yyyy').format(widget.date)}'),
      ),
      body: journal.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (state) {
          final entries = state.entries;
          if (state.dayId == null) {
            return const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'Aucune séance enregistrée ce jour — rien à bilanter.',
                ),
              ),
            );
          }

          return FutureBuilder(
            future: _loadReviewAndEntries(repo, state.dayId!),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());
              if (!_loaded) {
                _loaded = true;
                final (review, savedEntries) = snapshot.data!;
                final (mood, restNotes) = _extractMood(
                  review.generalNotes ?? '',
                );
                _selectedMood = mood;
                _notesController.text = restNotes;
                for (final saved in savedEntries) {
                  _statusOverrides[saved.journalEntryId] = saved.status;
                  if (saved.notes != null) {
                    _entryNoteControllers
                            .putIfAbsent(
                              saved.journalEntryId,
                              () => TextEditingController(),
                            )
                            .text =
                        saved.notes!;
                  }
                }
              }

              return ListView(
                // Marge basse étendue : cet écran est empilé dans le
                // Navigator de l'onglet Classe, donc affiché derrière la
                // barre de navigation flottante de l'app — sans elle, le
                // bouton « Enregistrer le bilan », dernier élément de cette
                // liste, peut se retrouver sous la barre (voir
                // AppSpacing.bottomNavClearance).
                padding: const EdgeInsets.fromLTRB(16, 16, 16, AppSpacing.bottomNavClearance),
                children: [
                  Text(
                    'Comment s\'est passée la journée ? Ce que vous écrivez ici aide l\'IA à '
                    'mieux préparer les prochaines séances.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Humeur de la classe',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: _moods.map((m) {
                      final (emoji, label) = m;
                      final selected = _selectedMood == emoji;
                      return ChoiceChip(
                        label: Text('$emoji  $label'),
                        selected: selected,
                        selectedColor: AppColors.accent.withValues(alpha: 0.18),
                        onSelected: (_) => setState(
                          () => _selectedMood = selected ? null : emoji,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _notesController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Impressions générales, comportements, ce qui a bien/mal fonctionné…',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Séances de la journée',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...entries.map((e) {
                    _entryNoteControllers.putIfAbsent(
                      e.id,
                      () => TextEditingController(),
                    );
                    final status = _statusOverrides[e.id] ?? e.status;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.title?.isNotEmpty == true
                                  ? e.title!
                                  : e.subjectLabel,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              children: _statusLabels.entries
                                  .map(
                                    (se) => ChoiceChip(
                                      label: Text(
                                        se.value,
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      selected: status == se.key,
                                      onSelected: (_) => setState(
                                        () => _statusOverrides[e.id] = se.key,
                                      ),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _entryNoteControllers[e.id],
                              decoration: const InputDecoration(
                                isDense: true,
                                hintText: 'Note pour cette séance (facultatif)',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saving
                          ? null
                          : () => _save(state.dayId, entries),
                      child: _saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Enregistrer le bilan'),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
