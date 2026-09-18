import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/result/result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../data/repositories/exercises_repository.dart';
import '../journal_providers.dart';
import '../reject_feedback_dialog.dart';
import 'exercices_providers.dart';
import 'exercice_sheet_view.dart';

/// Génère une fiche d'exercices sur 2 niveaux pour une séance du cahier
/// journal (§4) : la matière est celle de la séance, implicite. Le parcours :
/// indications libres (facultatives) → génération → relecture → validation.
/// Rien n'est écrit dans `exercise_sheets` avant que Sandra n'ait validé (R1).
Future<void> showExercicesGenerationSheet(
  BuildContext context, {
  required String entryId,
  required String seanceLabel,
  required DateTime seanceDate,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _ExercicesSheet(
      entryId: entryId,
      seanceLabel: seanceLabel,
      seanceDate: seanceDate,
    ),
  );
}

/// Génère une fiche d'exercices **sans partir d'une séance déjà saisie** :
/// Sandra choisit d'abord la matière, puis décrit ce qu'elle veut (demande
/// explicite du 16 septembre 2026 — jusqu'ici la génération n'existait que
/// depuis le menu d'une séance existante, ce qui imposait la matière).
Future<void> showExercicesForDomainSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => const _ExercicesSheet(),
  );
}

enum _Phase { demande, generation, rateLimited, validationFailed, error, relecture }

/// Durées proposées : une fiche occupe une partie du créneau, pas tout —
/// le reste de la séance sert au tissage, à la consigne et à la correction.
const _durees = [15, 20, 30, 40];

class _ExercicesSheet extends ConsumerStatefulWidget {
  /// Mode séance : `entryId`/`seanceLabel`/`seanceDate` renseignés, la
  /// matière est fixée par la séance. Mode matière : les trois sont `null`,
  /// un sélecteur de domaine apparaît dans l'écran de demande et le jour visé
  /// démarre sur aujourd'hui (modifiable avant l'enregistrement).
  const _ExercicesSheet({this.entryId, this.seanceLabel, this.seanceDate})
      : assert(
          (entryId == null) == (seanceLabel == null),
          'entryId et seanceLabel vont ensemble ou pas du tout.',
        );

  final String? entryId;
  final String? seanceLabel;
  final DateTime? seanceDate;

  bool get isDomainMode => entryId == null;

  @override
  ConsumerState<_ExercicesSheet> createState() => _ExercicesSheetState();
}

class _ExercicesSheetState extends ConsumerState<_ExercicesSheet> {
  final _consigneController = TextEditingController();
  _Phase _phase = _Phase.demande;
  String? _selectedDomainCode;
  String? _selectedDomainLabel;
  int? _duree;
  DateTime? _retryAt;
  Duration _remaining = Duration.zero;
  Timer? _timer;
  List<String> _errors = const [];
  String? _errorMessage;
  String? _propositionId;
  Map<String, dynamic>? _payload;
  bool _applying = false;

  /// Jour visé et séance liée au moment d'enregistrer (Sandra, 16 septembre
  /// 2026 : générer un exercice puis l'enregistrer pour le lendemain, ou le
  /// jour même, et le lier à un cours). Initialisés à des valeurs cohérentes
  /// dès qu'une fiche est proposée ; modifiables jusqu'à la validation, et de
  /// nouveau après coup depuis la fiche enregistrée (exercice_sheet_view.dart).
  DateTime? _scheduleDate;
  String? _scheduleEntryId;

  @override
  void dispose() {
    _timer?.cancel();
    _consigneController.dispose();
    super.dispose();
  }

  String get _targetLabel => widget.isDomainMode
      ? (_selectedDomainLabel ?? 'Choisissez une matière')
      : widget.seanceLabel!;

  bool get _canGenerate => widget.isDomainMode ? _selectedDomainCode != null : true;

  Future<void> _generate() async {
    setState(() {
      _phase = _Phase.generation;
      _errorMessage = null;
    });
    try {
      final outcome = await ref.read(exercisesRepositoryProvider).generate(
            entryId: widget.entryId,
            domainCode: widget.isDomainMode ? _selectedDomainCode : null,
            consigneLibre: _consigneController.text,
            dureeMin: _duree,
          );
      if (!mounted) return;
      switch (outcome) {
        case ExercisesGenerated(:final propositionId, :final payload):
          setState(() {
            _phase = _Phase.relecture;
            _propositionId = propositionId;
            _payload = payload;
            _scheduleDate ??= widget.seanceDate ?? DateTime.now();
            _scheduleEntryId ??= widget.entryId;
          });
        case ExercisesRateLimited(:final retryAt):
          _startCountdown(retryAt);
        case ExercisesValidationFailed(:final details):
          setState(() {
            _phase = _Phase.validationFailed;
            _errors = details;
          });
      }
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.error;
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.error;
        _errorMessage = e.toString();
      });
    }
  }

  void _startCountdown(DateTime retryAt) {
    _timer?.cancel();
    setState(() {
      _phase = _Phase.rateLimited;
      _retryAt = retryAt;
      _remaining = retryAt.difference(DateTime.now());
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = _retryAt!.difference(DateTime.now());
      if (remaining.isNegative || remaining == Duration.zero) {
        _timer?.cancel();
        _generate();
        return;
      }
      if (mounted) setState(() => _remaining = remaining);
    });
  }

  Future<void> _accept() async {
    setState(() => _applying = true);
    try {
      final repo = ref.read(exercisesRepositoryProvider);
      final sheetId = await repo.accept(_propositionId!);
      final finalDate = _scheduleDate ?? widget.seanceDate ?? DateTime.now();
      // Toujours appelée : même quand rien n'a été changé, elle ne fait que
      // confirmer les valeurs par défaut déjà posées par apply_ai_proposition
      // — plus simple que de détecter si Sandra a modifié la proposition.
      await repo.updateSchedule(
        sheetId,
        date: finalDate,
        entryId: _scheduleEntryId,
        unlinkEntry: _scheduleEntryId == null,
      );
      if (!mounted) return;
      if (widget.entryId != null) ref.invalidate(sheetsForEntryProvider(widget.entryId!));
      if (_scheduleEntryId != null && _scheduleEntryId != widget.entryId) {
        ref.invalidate(sheetsForEntryProvider(_scheduleEntryId!));
      }
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Fiche d\'exercices enregistrée.'),
          action: SnackBarAction(
            label: 'Ouvrir',
            onPressed: () => showExerciceSheetView(
              navigator.context,
              sheet: ExerciseSheet.fromPayload(
                id: sheetId,
                date: finalDate,
                subjectLabel: _targetLabel,
                payload: _payload!,
                entryId: _scheduleEntryId,
              ),
            ),
          ),
        ),
      );
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _applying = false;
        _errorMessage = e.message;
      });
    }
  }

  /// Rejette la proposition. Si Sandra explique pourquoi ou ce qu'elle
  /// voudrait à la place, la fiche est aussitôt regénérée avec sa remarque
  /// fondue dans la consigne libre — même geste que pour une séance
  /// (generation_validation_screen.dart), demandé le même jour.
  Future<void> _reject() async {
    final feedback = await showDialog<String>(
      context: context,
      builder: (context) => const RejectFeedbackDialog(),
    );
    if (feedback == null) return; // annulé : la proposition reste en attente

    await ref.read(exercisesRepositoryProvider).reject(_propositionId!);
    if (!mounted) return;

    if (feedback.trim().isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    _consigneController.text = [_consigneController.text, feedback.trim()]
        .where((s) => s.trim().isNotEmpty)
        .join('\n');
    await _generate();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Voir AppSpacing.bottomNavClearance : feuille modale ouverte depuis un
      // onglet, donc affichée derrière la barre de navigation flottante.
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 4,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.bottomNavClearance,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: SingleChildScrollView(child: _buildBody(context)),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);

    switch (_phase) {
      case _Phase.demande:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.aiProposed),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Fiche d\'exercices', style: theme.textTheme.titleLarge),
                ),
              ],
            ),
            if (!widget.isDomainMode) ...[
              const SizedBox(height: 4),
              Text(widget.seanceLabel!, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: 16),
            Text(
              'La fiche sera générée en deux versions du même travail : une avec '
              'aides pour les élèves qui en ont besoin, une en autonomie. Rien '
              'n\'est enregistré avant que vous ne validiez.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            if (widget.isDomainMode) ...[
              _DomainPicker(
                selectedCode: _selectedDomainCode,
                onSelected: (code, label) => setState(() {
                  _selectedDomainCode = code;
                  _selectedDomainLabel = label;
                }),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _consigneController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Indications particulières'
                    '${widget.isDomainMode ? '' : ' (facultatif)'}',
                hintText: widget.isDomainMode
                    ? 'Ex. : petite révision avant l\'évaluation, niveau simple.'
                    : 'Ex. : beaucoup confondent encore le verbe et le sujet.',
                helperText: widget.isDomainMode
                    ? 'Sans séance à suivre, c\'est ce qui guide le plus l\'IA.'
                    : null,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            Text('Durée de travail visée', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Automatique'),
                  selected: _duree == null,
                  onSelected: (_) => setState(() => _duree = null),
                ),
                for (final d in _durees)
                  ChoiceChip(
                    label: Text('$d min'),
                    selected: _duree == d,
                    onSelected: (_) => setState(() => _duree = d),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _canGenerate ? _generate : null,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Générer la fiche'),
              ),
            ),
          ],
        );

      case _Phase.generation:
        return const _Centered(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('L\'IA prépare les deux niveaux…'),
            ],
          ),
        );

      case _Phase.rateLimited:
        final seconds = _remaining.inSeconds.clamp(0, 999);
        return _Centered(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.hourglass_top_outlined, size: 40),
              const SizedBox(height: 12),
              const Text('Quota de l\'IA atteint.'),
              const SizedBox(height: 4),
              Text('Nouvel essai automatique dans 0:${seconds.toString().padLeft(2, '0')}'),
            ],
          ),
        );

      case _Phase.validationFailed:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'La fiche générée ne respecte pas les règles :',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ..._errors.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $e', style: theme.textTheme.bodySmall),
                )),
            const SizedBox(height: 16),
            FilledButton(onPressed: _generate, child: const Text('Réessayer')),
          ],
        );

      case _Phase.error:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Erreur : $_errorMessage'),
            const SizedBox(height: 16),
            FilledButton(onPressed: _generate, child: const Text('Réessayer')),
          ],
        );

      case _Phase.relecture:
        final sheet = ExerciseSheet.fromPayload(
          id: '',
          date: _scheduleDate ?? widget.seanceDate ?? DateTime.now(),
          subjectLabel: _targetLabel,
          payload: _payload!,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                tooltip: 'Plein écran',
                icon: const Icon(Icons.open_in_full),
                onPressed: () => openExerciceSheetFullscreen(context, sheet),
              ),
            ),
            ExerciceSheetBody(sheet: sheet, showAttendu: true),
            const SizedBox(height: 12),
            _SchedulePicker(
              date: _scheduleDate ?? widget.seanceDate ?? DateTime.now(),
              entryId: _scheduleEntryId,
              onChanged: (date, entryId) => setState(() {
                _scheduleDate = date;
                _scheduleEntryId = entryId;
              }),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.aiProposed.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.visibility_outlined, size: 18, color: AppColors.aiProposed),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Relisez les exemples avant de valider : l\'IA se trompe '
                      'parfois sur un mot ou un calcul.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null) ...[
              Text(_errorMessage!, style: TextStyle(color: theme.colorScheme.error)),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                TextButton(
                  onPressed: _applying ? null : _reject,
                  child: const Text('Rejeter'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _applying ? null : _accept,
                  child: _applying
                      ? const SizedBox(
                          height: 18, width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Valider et enregistrer'),
                ),
              ],
            ),
          ],
        );
    }
  }
}

/// Sélecteur de matière (mode autonome) : mêmes domaines et même présentation
/// à deux lignes que la vue Journal « Par matière » (les abréviations du
/// référentiel type `FR.CNJ` ne veulent rien dire pour Sandra).
class _DomainPicker extends ConsumerWidget {
  const _DomainPicker({required this.selectedCode, required this.onSelected});

  final String? selectedCode;
  final void Function(String code, String label) onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final domains = ref.watch(exercisesDomainsProvider);

    return domains.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text('Erreur : $e', style: TextStyle(color: Theme.of(context).colorScheme.error)),
      data: (list) {
        if (list.isEmpty) {
          return const Text('Aucune matière rattachée à l\'emploi du temps.');
        }
        return DropdownButtonFormField<String>(
          initialValue: selectedCode,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Matière'),
          hint: const Text('Choisir une matière'),
          selectedItemBuilder: (context) => list
              .map((d) => Align(
                    alignment: Alignment.centerLeft,
                    child: Text(d.fullLabel, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          items: [
            for (final d in list)
              DropdownMenuItem(
                value: d.code,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(d.subjectLabel, style: Theme.of(context).textTheme.labelSmall),
                    Text(d.label, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
          ],
          onChanged: (code) {
            if (code == null) return;
            final domain = list.firstWhere((d) => d.code == code);
            onSelected(code, domain.fullLabel);
          },
        );
      },
    );
  }
}

/// `HH:MM` à partir d'un `time` Postgres (`HH:MM:SS`).
String _timeLabel(String? time) => (time != null && time.length >= 5) ? time.substring(0, 5) : '';

/// Jour visé et séance liée, modifiables avant l'enregistrement (Sandra, 16
/// septembre 2026 : « Sandra génère un exercice mais l'enregistre pour le
/// lendemain ou pour le jour même et le lie à un cours »). La liste des
/// séances proposées dépend du jour choisi : en changer vide le choix
/// précédent, qui ne correspondrait plus à rien ce jour-là.
class _SchedulePicker extends ConsumerWidget {
  const _SchedulePicker({required this.date, required this.entryId, required this.onChanged});

  final DateTime date;
  final String? entryId;
  final void Function(DateTime date, String? entryId) onChanged;

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: now.subtract(const Duration(days: 60)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) onChanged(picked, null);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dayState = ref.watch(dayJournalProvider(date));

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_outlined, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Enregistrer pour le ${DateFormat('EEEE d MMMM', 'fr_FR').format(date)}',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(onPressed: () => _pickDate(context), child: const Text('Changer')),
            ],
          ),
          const SizedBox(height: 8),
          dayState.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Erreur : $e', style: TextStyle(color: theme.colorScheme.error)),
            data: (state) {
              final entries = state.entries;
              final validEntryId = entries.any((e) => e.id == entryId) ? entryId : null;
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
                onChanged: (v) => onChanged(date, v),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Centered extends StatelessWidget {
  const _Centered({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(child: child),
      );
}
