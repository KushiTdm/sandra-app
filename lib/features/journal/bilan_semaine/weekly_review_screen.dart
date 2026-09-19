import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/result/result.dart';
import '../../../core/supabase/supabase_bootstrap.dart';
import '../../../data/repositories/weekly_review_repository.dart';
import '../generation/generation_screen.dart';
import '../generation/generation_validation_screen.dart';

final weeklyReviewRepositoryProvider = Provider<WeeklyReviewRepository>((ref) => WeeklyReviewRepository(supabase));

/// Bilan de la semaine (§10) : résumé (absences, comportements, sujets
/// traités, notions vues, difficultés, prévu vs réalisé) rédigé par l'IA à
/// partir de données déjà vérifiées, puis — si Sandra le souhaite —
/// préparation de la semaine suivante avec l'IA. Le résumé nourrit
/// automatiquement cette préparation (`build_generation_context`, 0034) :
/// rien à faire ici pour ça, c'est côté serveur.
///
/// La préparation elle-même réutilise le pipeline `generate-journal`
/// existant (`GenerationScreen`/`GenerationValidationScreen`, §9.5-9.9) —
/// chaque séance ou fiche d'exercices proposée s'y valide ou s'y refuse
/// individuellement, avec commentaire facultatif qui relance une
/// régénération, exactement ce que demande le bilan de semaine.
class WeeklyReviewScreen extends ConsumerStatefulWidget {
  const WeeklyReviewScreen({super.key, required this.classId, required this.weekStart});

  final String classId;

  /// Le lundi de la semaine dont on fait le bilan.
  final DateTime weekStart;

  @override
  ConsumerState<WeeklyReviewScreen> createState() => _WeeklyReviewScreenState();
}

class _WeeklyReviewScreenState extends ConsumerState<WeeklyReviewScreen> {
  WeeklyReview? _weekly;
  bool _loading = true;
  bool _generating = false;
  String? _error;
  DateTime? _retryAt;

  DateTime get _nextMonday => widget.weekStart.add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final weekly = await ref.read(weeklyReviewRepositoryProvider).find(
            classId: widget.classId,
            weekStart: widget.weekStart,
          );
      if (mounted) setState(() => _weekly = weekly);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _generate() async {
    setState(() {
      _generating = true;
      _error = null;
    });
    try {
      final weekly = await ref.read(weeklyReviewRepositoryProvider).generate(widget.weekStart);
      if (mounted) setState(() => _weekly = weekly);
    } on WeeklyReviewRateLimited catch (e) {
      if (mounted) setState(() => _retryAt = e.retryAt);
    } on AppException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Future<void> _prepareNextWeek() async {
    final weekly = _weekly;
    if (weekly == null) return;
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => GenerationScreen(
        classId: widget.classId,
        initialScope: 'semaine',
        initialDateFrom: _nextMonday,
        onRequestCreated: (requestId) async {
          try {
            await ref.read(weeklyReviewRepositoryProvider).linkGenerationRequest(weekly.id, requestId);
          } on AppException {
            // Non bloquant : la génération continue même si le lien échoue —
            // Sandra retrouve ses propositions depuis Journal > Générer.
          }
        },
      ),
    ));
    await _load(); // recharge pour retrouver generation_request_id à jour
  }

  void _openPropositions() {
    final requestId = _weekly?.generationRequestId;
    if (requestId == null) return;
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => GenerationValidationScreen(requestId: requestId),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final weekEnd = widget.weekStart.add(const Duration(days: 4));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Semaine du ${DateFormat('d MMMM', 'fr_FR').format(widget.weekStart)} '
          'au ${DateFormat('d MMMM', 'fr_FR').format(weekEnd)}',
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_weekly == null) ...[
                  Text(
                    'Aucun bilan n\'a encore été généré pour cette semaine.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  if (_retryAt != null)
                    Text(
                      'Quota de l\'IA atteint, réessayez dans '
                      '${_retryAt!.difference(DateTime.now()).inSeconds.clamp(0, 999)}s.',
                    ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ),
                  FilledButton.icon(
                    onPressed: _generating ? null : _generate,
                    icon: _generating
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.auto_awesome),
                    label: const Text('Générer le bilan de la semaine'),
                  ),
                ] else ...[
                  MarkdownBody(
                    data: _weekly!.narrative ?? '(bilan sans texte rédigé)',
                    selectable: true,
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _generating ? null : _generate,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Regénérer le bilan'),
                  ),
                  const Divider(height: 32),
                  Text('Semaine prochaine', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'L\'IA tient compte de ce bilan (absences, difficultés, ce qui '
                    'n\'a pas pu être fait) pour préparer la semaine du '
                    '${DateFormat('d MMMM', 'fr_FR').format(_nextMonday)}.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  if (_weekly!.generationRequestId != null)
                    FilledButton.icon(
                      onPressed: _openPropositions,
                      icon: const Icon(Icons.fact_check_outlined),
                      label: const Text('Voir les propositions de la semaine prochaine'),
                    )
                  else
                    FilledButton.icon(
                      onPressed: _prepareNextWeek,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Préparer la semaine prochaine avec l\'IA'),
                    ),
                ],
              ],
            ),
    );
  }
}
