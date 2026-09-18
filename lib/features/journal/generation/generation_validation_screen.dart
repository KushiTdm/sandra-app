import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/result/result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../data/repositories/ai_repository.dart';
import '../ai_generation_sheet.dart';
import '../reject_feedback_dialog.dart';
import 'generation_providers.dart';

/// Boîte de validation d'une génération jour/semaine (§9.6 phase 4) : les
/// propositions sont des `ai_propositions` ordinaires (type='seance'), la
/// même validation que pour une séance isolée s'applique séance par séance
/// (R1) — juste listées ensemble ici parce qu'elles viennent de la même
/// demande.
class GenerationValidationScreen extends ConsumerStatefulWidget {
  const GenerationValidationScreen({super.key, required this.requestId});

  final String requestId;

  @override
  ConsumerState<GenerationValidationScreen> createState() => _GenerationValidationScreenState();
}

class _GenerationValidationScreenState extends ConsumerState<GenerationValidationScreen> {
  List<Map<String, dynamic>>? _propositions;
  final Set<String> _decided = {};
  final Set<String> _regenerating = {};
  bool _bulkRunning = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final rows = await ref.read(generationRepositoryProvider).propositionsForRequest(widget.requestId);
      if (!mounted) return;
      setState(() => _propositions = rows);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  Future<void> _accept(String id) async {
    try {
      await ref.read(aiRepositoryProvider).applyProposition(id);
      if (!mounted) return;
      setState(() => _decided.add(id));
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Échec : ${e.message}')));
    }
  }

  /// Rejette une proposition. Si Sandra a expliqué pourquoi ou ce qu'elle
  /// veut à la place (demande explicite du 16 septembre 2026), on redemande
  /// aussitôt une séance pour ce même créneau avec ses indications — sans
  /// qu'elle ait à retrouver le créneau vide ailleurs dans l'app.
  Future<void> _reject(Map<String, dynamic> p) async {
    final id = p['id'] as String;
    final feedback = await showDialog<String>(
      context: context,
      builder: (context) => const RejectFeedbackDialog(),
    );
    if (feedback == null) return; // annulé : la proposition reste en attente

    try {
      await ref.read(aiRepositoryProvider).rejectProposition(id);
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Échec : ${e.message}')));
      return;
    }
    if (!mounted) return;
    setState(() => _decided.add(id));

    if (feedback.trim().isEmpty) return; // rejet simple, sans regénération

    final scope = (p['scope'] as Map?)?.cast<String, dynamic>();
    final slotId = scope?['slot_id'] as String?;
    final dateStr = scope?['date'] as String?;
    if (slotId == null || dateStr == null) return; // pas de créneau nominal à regénérer

    setState(() => _regenerating.add(id));
    try {
      final outcome = await ref.read(aiRepositoryProvider).generateLesson(
            slotId: slotId,
            date: DateTime.parse(dateStr),
            consigneLibre: feedback.trim(),
          );
      if (!mounted) return;
      switch (outcome) {
        case GenerateLessonSuccess():
          await _load(); // la nouvelle proposition apparaît dans la liste
        case GenerateLessonRateLimited(:final retryAt):
          final seconds = retryAt.difference(DateTime.now()).inSeconds.clamp(0, 999);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Quota de l\'IA atteint — réessayez dans ${seconds}s.')),
          );
        case GenerateLessonValidationFailed(:final details):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Nouvelle proposition invalide : ${details.join(" ; ")}')),
          );
      }
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Échec : ${e.message}')));
      }
    } finally {
      if (mounted) setState(() => _regenerating.remove(id));
    }
  }

  Future<void> _acceptAllPending() async {
    setState(() => _bulkRunning = true);
    for (final p in _propositions ?? []) {
      final id = p['id'] as String;
      if (!_decided.contains(id)) await _accept(id);
    }
    if (mounted) setState(() => _bulkRunning = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(appBar: AppBar(title: const Text('Propositions')), body: Center(child: Text('Erreur : $_error')));
    }
    if (_propositions == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final byDate = <String, List<Map<String, dynamic>>>{};
    for (final p in _propositions!) {
      byDate.putIfAbsent(p['target_date'] as String, () => []).add(p);
    }
    final dates = byDate.keys.toList()..sort();
    final pendingCount = _propositions!.where((p) => !_decided.contains(p['id'])).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_propositions!.length} séance(s) proposée(s)'),
        actions: [
          if (pendingCount > 0)
            TextButton(
              onPressed: _bulkRunning ? null : _acceptAllPending,
              child: Text('Tout valider ($pendingCount)', style: const TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: _propositions!.isEmpty
          ? const Center(child: Text('Aucune proposition pour cette génération.'))
          : ListView(
              // Voir AppSpacing.bottomNavClearance : cet écran est empilé
              // dans le Navigator de l'onglet Journal, donc affiché derrière
              // la barre de navigation flottante — sans cette marge, le
              // Valider/Rejeter de la dernière proposition de la liste peut
              // s'y retrouver coincé, inatteignable même en faisant défiler
              // (signalé par Sandra, 16 septembre 2026).
              padding: const EdgeInsets.fromLTRB(12, 12, 12, AppSpacing.bottomNavClearance),
              children: [
                for (final date in dates) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(DateTime.parse(date)),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  for (final p in byDate[date]!) _buildPropositionCard(p),
                ],
              ],
            ),
    );
  }

  Widget _buildPropositionCard(Map<String, dynamic> p) {
    final id = p['id'] as String;
    final payload = (p['payload'] as Map).cast<String, dynamic>();
    final horaire = (payload['horaire'] as Map?)?.cast<String, dynamic>();
    final decided = _decided.contains(id);
    final regenerating = _regenerating.contains(id);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, size: 16, color: AppColors.aiProposed),
                const SizedBox(width: 6),
                if (horaire != null)
                  Text('${(horaire['debut'] as String).substring(0, 5)}–${(horaire['fin'] as String).substring(0, 5)}  ',
                      style: Theme.of(context).textTheme.bodySmall),
                Expanded(child: Text(payload['domaine'] as String? ?? '', style: Theme.of(context).textTheme.bodySmall)),
              ],
            ),
            const SizedBox(height: 4),
            Text(payload['intitule'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(payload['objectif'] as String? ?? '', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            if (regenerating)
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 8),
                  Text('Nouvelle proposition en cours…'),
                ],
              )
            else if (decided)
              Text('Décidé', style: TextStyle(color: Theme.of(context).colorScheme.outline, fontStyle: FontStyle.italic))
            else
              Row(
                children: [
                  TextButton(onPressed: () => _reject(p), child: const Text('Rejeter')),
                  const Spacer(),
                  FilledButton(onPressed: () => _accept(id), child: const Text('Valider')),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// RejectFeedbackDialog : voir reject_feedback_dialog.dart (partagée avec
// _ExercicesSheet, même besoin exprimé par Sandra le même jour).
