import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/result/result.dart';
import '../../core/supabase/supabase_bootstrap.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/repositories/ai_repository.dart';
import 'journal_providers.dart';

final aiRepositoryProvider = Provider<AiRepository>((ref) => AiRepository(supabase));

/// Génère une séance IA pour un créneau vide (§8.1, §9.1-9.3), avec le
/// compte à rebours du limiteur de débit (§9.7) et la boîte de validation
/// avant toute écriture réelle (R1).
Future<void> showAiGenerationSheet(
  BuildContext context, {
  required String slotId,
  required DateTime date,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _AiGenerationSheet(
      date: date,
      generate: (ref) => ref.read(aiRepositoryProvider).generateLesson(slotId: slotId, date: date),
    ),
  );
}

/// Demande à l'IA de corriger une séance existante — proposition en attente
/// ou déjà validée (CRUD sur le contenu généré, demandé explicitement par
/// Sandra) : la modification manuelle et la suppression passent par
/// l'éditeur structuré habituel, seule la correction assistée par IA a
/// besoin d'un parcours dédié.
Future<void> showAiCorrectionSheet(
  BuildContext context, {
  required String entryId,
  required DateTime date,
}) async {
  final instruction = await showDialog<String>(
    context: context,
    builder: (context) => const _CorrectionInstructionDialog(),
  );
  if (instruction == null || instruction.trim().isEmpty) return;
  if (!context.mounted) return;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _AiGenerationSheet(
      date: date,
      generate: (ref) => ref.read(aiRepositoryProvider).correctLesson(
            entryId: entryId,
            correctionInstruction: instruction.trim(),
          ),
    ),
  );
}

class _CorrectionInstructionDialog extends StatefulWidget {
  const _CorrectionInstructionDialog();

  @override
  State<_CorrectionInstructionDialog> createState() => _CorrectionInstructionDialogState();
}

class _CorrectionInstructionDialogState extends State<_CorrectionInstructionDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Demander une correction à l\'IA'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: 'Ex. : la différenciation n\'est pas assez précise, revois-la.',
        ),
        onSubmitted: (v) => Navigator.of(context).pop(v),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler')),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Envoyer'),
        ),
      ],
    );
  }
}

enum _Phase { loading, rateLimited, validationFailed, error, review }

class _AiGenerationSheet extends ConsumerStatefulWidget {
  const _AiGenerationSheet({required this.date, required this.generate});

  final DateTime date;
  final Future<GenerateLessonOutcome> Function(WidgetRef ref) generate;

  @override
  ConsumerState<_AiGenerationSheet> createState() => _AiGenerationSheetState();
}

class _AiGenerationSheetState extends ConsumerState<_AiGenerationSheet> {
  _Phase _phase = _Phase.loading;
  DateTime? _retryAt;
  Duration _remaining = Duration.zero;
  Timer? _timer;
  List<String> _errors = [];
  String? _errorMessage;
  String? _propositionId;
  Map<String, dynamic>? _payload;
  bool _applying = false;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _generate() async {
    setState(() => _phase = _Phase.loading);
    try {
      final outcome = await widget.generate(ref);
      if (!mounted) return;
      switch (outcome) {
        case GenerateLessonSuccess(:final propositionId, :final payload):
          setState(() {
            _phase = _Phase.review;
            _propositionId = propositionId;
            _payload = payload;
          });
        case GenerateLessonRateLimited(:final retryAt):
          _startCountdown(retryAt);
        case GenerateLessonValidationFailed(:final details):
          setState(() {
            _phase = _Phase.validationFailed;
            _errors = details;
          });
      }
    } on AppException catch (e) {
      setState(() {
        _phase = _Phase.error;
        _errorMessage = e.message;
      });
    } catch (e) {
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
      setState(() => _remaining = remaining);
    });
  }

  Future<void> _accept() async {
    setState(() => _applying = true);
    try {
      await ref.read(aiRepositoryProvider).applyProposition(_propositionId!);
      if (!mounted) return;
      ref.invalidate(dayJournalProvider(widget.date));
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cahier journal mis à jour.')),
      );
    } on AppException catch (e) {
      setState(() {
        _applying = false;
        _errorMessage = e.message;
      });
    }
  }

  Future<void> _reject() async {
    await ref.read(aiRepositoryProvider).rejectProposition(_propositionId!);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Voir AppSpacing.bottomNavClearance : feuille modale ouverte depuis un
      // onglet, donc affichée derrière la barre de navigation flottante —
      // c'est ce qui rendait « Valider »/« Rejeter » inatteignables ici,
      // signalé par Sandra sur une capture d'écran (16 septembre 2026).
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.bottomNavClearance,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: SingleChildScrollView(child: _buildBody(context)),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_phase) {
      case _Phase.loading:
        return const _Centered(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('L\'IA travaille sur la séance…'),
          ],
        ));

      case _Phase.rateLimited:
        final seconds = _remaining.inSeconds.clamp(0, 999);
        return _Centered(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.hourglass_top_outlined, size: 40),
              const SizedBox(height: 12),
              const Text('Limite de débit Mistral atteinte.'),
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
            Text('La proposition générée ne respecte pas les règles :', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ..._errors.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $e'),
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

      case _Phase.review:
        return _ReviewContent(
          payload: _payload!,
          applying: _applying,
          onAccept: _accept,
          onReject: _reject,
        );
    }
  }
}

class _Centered extends StatelessWidget {
  const _Centered({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.all(32), child: Center(child: child));
}

class _ReviewContent extends StatelessWidget {
  const _ReviewContent({
    required this.payload,
    required this.applying,
    required this.onAccept,
    required this.onReject,
  });

  final Map<String, dynamic> payload;
  final bool applying;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final deroulement = (payload['deroulement'] as Map<String, dynamic>? ?? {});
    const phaseLabels = {
      'tissage': 'Tissage',
      'consigne_decouverte': 'Consigne / découverte',
      'recherche_application': 'Recherche / application',
      'correction': 'Correction',
      'institutionnalisation': 'Institutionnalisation',
    };
    final differenciation = payload['differenciation'] as Map<String, dynamic>? ?? {};
    final materiel = (payload['materiel'] as List? ?? []).cast<String>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome, size: 18, color: Color(0xFF6B5CA5)),
            const SizedBox(width: 6),
            Expanded(
              child: Text('Proposé par l\'IA', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: const Color(0xFF6B5CA5))),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(payload['intitule'] as String? ?? '', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(payload['competence_bo'] as String? ?? '', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 12),
        Text(payload['objectif'] as String? ?? ''),
        const SizedBox(height: 16),
        Text('Déroulement', style: Theme.of(context).textTheme.labelLarge),
        for (final entry in phaseLabels.entries)
          if (deroulement[entry.key] != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.value} (${deroulement[entry.key]['duree_min']} min)',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(deroulement[entry.key]['texte'] as String? ?? ''),
                ],
              ),
            ),
        const SizedBox(height: 16),
        Text('Différenciation', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        Text('FLSco : ${differenciation['flsco'] ?? ''}'),
        Text('Aide : ${differenciation['aide'] ?? ''}'),
        Text('Approfondissement : ${differenciation['approfondissement'] ?? ''}'),
        if (materiel.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Matériel', style: Theme.of(context).textTheme.labelLarge),
          Text(materiel.join(', ')),
        ],
        const SizedBox(height: 24),
        Row(
          children: [
            TextButton(
              onPressed: applying ? null : onReject,
              child: const Text('Rejeter'),
            ),
            const Spacer(),
            FilledButton(
              onPressed: applying ? null : onAccept,
              child: applying
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Valider'),
            ),
          ],
        ),
      ],
    );
  }
}
