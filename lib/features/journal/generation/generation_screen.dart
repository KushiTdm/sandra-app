import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/result/result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../data/repositories/generation_repository.dart';
import 'generation_providers.dart';
import 'generation_validation_screen.dart';

const _questionTypeLabels = {
  'choix_unique': 'Choix unique', 'choix_multiple': 'Choix multiple', 'oui_non': 'Oui / Non',
  'texte_court': 'Réponse libre', 'eleves': 'Élève(s)', 'notions': 'Notion(s)', 'echelle': 'Échelle',
};

enum _Step { configuration, contexte, questions, squelette, jours, termine }

/// Génération du cahier journal par l'IA, jour ou semaine (§9.5-9.9). Le
/// parcours (configuration → contexte → questions → squelette → détail jour
/// par jour) reprend exactement où il s'est arrêté si l'app est fermée en
/// cours de route : tout l'état vit dans `generation_requests`, jamais
/// seulement dans le téléphone.
class GenerationScreen extends ConsumerStatefulWidget {
  const GenerationScreen({super.key, required this.classId, this.resumeRequestId});

  final String classId;
  final String? resumeRequestId;

  @override
  ConsumerState<GenerationScreen> createState() => _GenerationScreenState();
}

class _GenerationScreenState extends ConsumerState<GenerationScreen> {
  _Step _step = _Step.configuration;

  // Configuration
  String _scope = 'jour';
  DateTime _dateFrom = _nextWeekday(DateTime.now());
  bool _regenerateExisting = false;

  // État de la demande en cours
  GenerationRequest? _request;
  Map<String, dynamic>? _contextPack;
  List<ClarificationQuestion> _questions = [];
  int _questionIndex = 0;
  final Map<String, String> _answers = {};
  final Map<String, bool> _rememberFlags = {};
  /// Indication libre facultative de Sandra pour cette génération précise
  /// (« sortie jeudi après-midi », « insister sur la soustraction »…) —
  /// transmise à l'IA au même titre que les réponses du wizard.
  final _consigneController = TextEditingController();
  List<SkeletonEntry> _skeleton = [];
  List<FlatSlot> _targetSlots = [];

  // Boucle jour par jour
  List<String> _distinctDates = [];
  final Set<String> _doneDates = {};
  final Map<String, String> _dayErrors = {};
  String? _currentProcessingDate;
  DateTime? _retryAt;
  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;

  bool _busy = false;
  String? _error;

  static DateTime _nextWeekday(DateTime from) {
    var d = DateTime(from.year, from.month, from.day);
    while (d.weekday > 5) {
      d = d.add(const Duration(days: 1));
    }
    return d;
  }

  static DateTime _fridayOfWeek(DateTime monday) => monday.add(Duration(days: 5 - monday.weekday));

  @override
  void initState() {
    super.initState();
    if (widget.resumeRequestId != null) _resume(widget.resumeRequestId!);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _consigneController.dispose();
    super.dispose();
  }

  Future<void> _resume(String requestId) async {
    setState(() => _busy = true);
    try {
      final repo = ref.read(generationRepositoryProvider);
      final req = await repo.loadRequest(requestId);
      _request = req;
      _contextPack = req.contextPack;
      _targetSlots = flattenTargetSlots(req.contextPack, req.regenerateExisting);
      _distinctDates = {for (final s in _targetSlots) s.date}.toList()..sort();
      _doneDates.addAll(req.processedDates.where((d) => req.dayErrors[d] == null));
      _dayErrors.addAll(req.dayErrors.map((k, v) => MapEntry(k, v.toString())));
      _skeleton = req.skeleton.cast<Map<String, dynamic>>().map(SkeletonEntry.fromJson).toList();

      if (req.status == 'contexte_pret') {
        setState(() => _step = _Step.contexte);
      } else if (req.status == 'questions_pretes') {
        _questions = req.questions.cast<Map<String, dynamic>>().map(ClarificationQuestion.fromJson).toList();
        setState(() => _step = _Step.questions);
      } else if (req.status == 'squelette_pret' || req.status == 'en_cours' || req.status == 'en_attente_debit') {
        setState(() => _step = _Step.jours);
        if (req.status == 'en_attente_debit' && req.retryAt != null) _startCountdown(req.retryAt!);
      } else {
        setState(() => _step = _Step.termine);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _loadContext() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repo = ref.read(generationRepositoryProvider);
      final dateTo = _scope == 'semaine' ? _fridayOfWeek(_dateFrom) : _dateFrom;
      final ctx = await repo.buildContext(classId: widget.classId, dateFrom: _dateFrom, dateTo: dateTo);
      setState(() {
        _contextPack = ctx;
        _targetSlots = flattenTargetSlots(ctx, _regenerateExisting);
        _step = _Step.contexte;
      });
    } on AppException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmContextAndAskQuestions() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repo = ref.read(generationRepositoryProvider);
      final dateTo = _scope == 'semaine' ? _fridayOfWeek(_dateFrom) : _dateFrom;
      final req = await repo.createRequest(
        classId: widget.classId,
        scope: _scope,
        dateFrom: _dateFrom,
        dateTo: dateTo,
        regenerateExisting: _regenerateExisting,
        contextPack: _contextPack!,
      );
      _request = req;
      // Transmise à l'IA dès la phase « questions » : une indication du type
      // « sortie jeudi après-midi » évite qu'elle pose une question dont
      // Sandra a déjà donné la réponse.
      final consigne = _consigneController.text.trim();
      if (consigne.isNotEmpty) {
        _answers['consigne_libre'] = consigne;
        await repo.saveAnswers(req.id, _answers);
      }
      final questions = await repo.requestQuestions(req.id);
      setState(() {
        _questions = questions;
        _questionIndex = 0;
        _step = _Step.questions;
      });
      if (questions.isEmpty) await _submitAnswersAndBuildSkeleton();
    } on AppException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submitAnswersAndBuildSkeleton() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repo = ref.read(generationRepositoryProvider);
      await repo.saveAnswers(_request!.id, _answers);
      await _savePreferencesFromAnswers(repo);
      final skeleton = await repo.requestSkeleton(_request!.id);
      _distinctDates = {for (final s in _targetSlots) s.date}.toList()..sort();
      setState(() {
        _skeleton = skeleton;
        _step = _Step.squelette;
      });
    } on AppException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Mémorise les réponses que Sandra a laissées cochées « Se souvenir »
  /// (§9.7) — au pire une préférence ne sera pas retenue si ça échoue, jamais
  /// bloquant pour la génération elle-même.
  Future<void> _savePreferencesFromAnswers(GenerationRepository repo) async {
    for (final q in _questions) {
      final key = q.clePreference;
      if (key == null || (_rememberFlags[q.id] ?? true) == false) continue;
      final answer = _answers[q.id];
      if (answer == null || answer.trim().isEmpty) continue;
      try {
        await repo.savePreference(key: key, value: answer);
      } on AppException {
        // Non bloquant : la génération continue même si l'enregistrement
        // d'une préférence échoue.
      }
    }
  }

  Future<void> _confirmSkeletonAndStartDays() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(generationRepositoryProvider).saveSkeleton(_request!.id, _skeleton);
      setState(() => _step = _Step.jours);
      await _generateNextDay();
    } on AppException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Prochaine date qui n'a encore jamais réussi ET n'est pas déjà marquée en
  /// erreur — une date en erreur n'est reprise que sur demande explicite
  /// (bouton « Réessayer »), jamais par l'avancement automatique, pour ne
  /// pas boucler indéfiniment sur le même jour qui échoue.
  String? get _nextPendingDate {
    final pending = _distinctDates.where((d) => !_doneDates.contains(d) && !_dayErrors.containsKey(d));
    return pending.isEmpty ? null : pending.first;
  }

  /// Avance vers le prochain jour à tenter. S'il n'en reste plus : bascule
  /// vers l'écran de fin seulement si tout a vraiment réussi — s'il reste ne
  /// serait-ce qu'un jour en erreur, on reste sur l'écran jour par jour, où
  /// il garde son bouton « Réessayer » et où « Voir les propositions » est
  /// déjà proposé pour ce qui a abouti (un jour qui échoue durablement ne
  /// doit jamais empêcher de valider les autres).
  Future<void> _continueOrFinish() async {
    final next = _nextPendingDate;
    if (next != null) {
      await _generateNextDay(next);
      return;
    }
    if (_doneDates.length == _distinctDates.length) {
      setState(() => _step = _Step.termine);
    }
  }

  Future<void> _generateNextDay([String? specificDate]) async {
    final date = specificDate ?? _nextPendingDate;
    if (date == null) {
      setState(() => _step = _Step.termine);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _currentProcessingDate = date;
    });
    try {
      final outcome = await ref.read(generationRepositoryProvider).generateDay(_request!.id, DateTime.parse(date));
      switch (outcome) {
        case DayGenerationSuccess():
          setState(() {
            _doneDates.add(date);
            _dayErrors.remove(date);
            _currentProcessingDate = null;
          });
          await _continueOrFinish();
        case DayGenerationRateLimited(:final retryAt):
          _currentProcessingDate = null;
          _startCountdown(retryAt);
        case DayGenerationValidationFailed(:final details):
          setState(() {
            _dayErrors[date] = details.join(' ; ');
            _currentProcessingDate = null;
          });
          await _continueOrFinish();
      }
    } on AppException catch (e) {
      setState(() {
        _error = e.message;
        _currentProcessingDate = null;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _startCountdown(DateTime retryAt) {
    _countdownTimer?.cancel();
    setState(() {
      _retryAt = retryAt;
      _remaining = retryAt.difference(DateTime.now());
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = retryAt.difference(DateTime.now());
      if (remaining.isNegative || remaining == Duration.zero) {
        _countdownTimer?.cancel();
        setState(() => _retryAt = null);
        _generateNextDay();
        return;
      }
      setState(() => _remaining = remaining);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Générer avec l\'IA')),
      // Marge basse à 104, pas 16 : cet écran est empilé dans le Navigator de
      // l'onglet Journal, donc toujours affiché derrière la barre de
      // navigation flottante de l'app (`AppShell`, `extendBody: true`). Sans
      // cette marge, le bouton de fin de chaque étape (« Continuer »,
      // « Suivant »/« Valider » du wizard, « Voir les propositions »…) vient
      // se placer tout en bas du corps — exactement la zone que la barre
      // recouvre — et devient invisible bien qu'il fonctionne (signalé par
      // Sandra : « bouton de validation du wizard non disponible »). Même
      // valeur que day_journal_view.dart, pour la même raison.
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, AppSpacing.bottomNavClearance),
        child: switch (_step) {
          _Step.configuration => _buildConfiguration(context),
          _Step.contexte => _buildContexte(context),
          _Step.questions => _buildQuestions(context),
          _Step.squelette => _buildSquelette(context),
          _Step.jours => _buildJours(context),
          _Step.termine => _buildTermine(context),
        },
      ),
    );
  }

  Widget _buildConfiguration(BuildContext context) {
    return ListView(
      children: [
        Text('Que voulez-vous préparer ?', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'jour', label: Text('Un jour')),
            ButtonSegment(value: 'semaine', label: Text('Une semaine')),
          ],
          selected: {_scope},
          onSelectionChanged: (s) => setState(() => _scope = s.first),
        ),
        const SizedBox(height: 20),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(_scope == 'jour' ? 'Jour' : 'Semaine du (lundi à vendredi)'),
          subtitle: Text(DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(_dateFrom)),
          trailing: const Icon(Icons.calendar_month_outlined),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _dateFrom,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 180)),
              selectableDayPredicate: (d) => d.weekday <= 5,
            );
            if (picked != null) setState(() => _dateFrom = picked);
          },
        ),
        if (_scope == 'semaine')
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Jusqu\'au ${DateFormat('EEEE d MMMM', 'fr_FR').format(_fridayOfWeek(_dateFrom))}.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Régénérer aussi les séances déjà prévues'),
          subtitle: const Text('Par défaut, seuls les créneaux encore vides sont préparés.'),
          value: _regenerateExisting,
          onChanged: (v) => setState(() => _regenerateExisting = v),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _consigneController,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Indications pour l\'IA (facultatif)',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
            hintText: 'Ex. : sortie à la BCD jeudi après-midi, insister sur la '
                'soustraction posée, éviter le travail en binôme cette semaine…',
          ),
        ),
        const SizedBox(height: 24),
        if (_error != null) Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ),
        FilledButton.icon(
          onPressed: _busy ? null : _loadContext,
          icon: _busy
              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.auto_awesome),
          label: const Text('Lancer la préparation'),
        ),
        const SizedBox(height: 8),
        Text(
          'Vous verrez d\'abord ce que l\'IA prend en compte, puis son plan — '
          'rien n\'est écrit dans le cahier journal sans votre validation.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildContexte(BuildContext context) {
    final ctx = _contextPack!;
    final cible = (ctx['cible'] as List?) ?? const [];
    final historique = (ctx['historique'] as List?) ?? const [];
    final remarques = (ctx['remarques'] as List?) ?? const [];
    final difficulte = (ctx['eleves_en_difficulte'] as List?) ?? const [];
    final vieDeClasse = (ctx['vie_de_classe'] as Map?) ?? const {};
    final namesAsync = ref.watch(studentDisplayNamesProvider);

    return ListView(
      children: [
        Text('Ce que l\'IA va prendre en compte', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Text('${_targetSlots.length} créneau(x) à préparer', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        for (final day in cible) _buildDayCard(context, day as Map<String, dynamic>),
        const SizedBox(height: 16),
        _InfoRow(icon: Icons.history, label: '${historique.length} séance(s) récente(s) prises en compte pour le tissage'),
        _InfoRow(icon: Icons.forum_outlined, label: '${remarques.length} remarque(s)/bilan(s) du soir pris en compte'),
        namesAsync.when(
          data: (names) => _InfoRow(
            icon: Icons.people_outline,
            label: difficulte.isEmpty
                ? 'Aucun élève signalé en difficulté récente'
                : '${difficulte.length} point(s) de vigilance élève — '
                    '${(difficulte.cast<Map<String, dynamic>>().map((d) => names[d['code']] ?? d['code']).toSet()).join(', ')}',
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        ),
        if (vieDeClasse.isNotEmpty)
          _InfoRow(
            icon: Icons.groups_outlined,
            label: 'Vie de classe (14 derniers jours) : ${vieDeClasse['absences_14j'] ?? 0} absence(s)'
                '${(vieDeClasse['signalements_par_type'] as Map?)?.isNotEmpty == true ? ', signalements : ${(vieDeClasse['signalements_par_type'] as Map).entries.map((e) => '${e.key} (${e.value})').join(', ')}' : ''}',
          ),
        const SizedBox(height: 24),
        if (_error != null) Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ),
        if (_targetSlots.isEmpty) ...[
          // Cas le plus fréquent — et le plus déroutant si on ne l'explique
          // pas : tous les créneaux du jour ont déjà une séance, donc il n'y a
          // rien à préparer et le bouton paraît « cassé ». On dit pourquoi, et
          // on propose l'action qui débloque, sur place.
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Rien à préparer ici',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _regenerateExisting
                        ? 'Cette période ne contient aucun créneau qui vous revienne '
                            '(uniquement des spécialistes, ou aucun emploi du temps ce jour-là).'
                        : 'Toutes vos séances de cette période sont déjà prévues. '
                            'Choisissez une autre date, ou demandez à l\'IA de refaire '
                            'celles qui existent déjà.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (!_regenerateExisting) ...[
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      onPressed: () => setState(() {
                        _regenerateExisting = true;
                        _targetSlots = flattenTargetSlots(_contextPack!, true);
                      }),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refaire les séances déjà prévues'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            TextButton(onPressed: _busy ? null : () => setState(() => _step = _Step.configuration), child: const Text('Retour')),
            const Spacer(),
            FilledButton(onPressed: _busy || _targetSlots.isEmpty ? null : _confirmContextAndAskQuestions, child: _busy
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : Text('Continuer (${_targetSlots.length} créneau${_targetSlots.length > 1 ? 'x' : ''})')),
          ],
        ),
      ],
    );
  }

  Widget _buildDayCard(BuildContext context, Map<String, dynamic> day) {
    final slots = (day['slots'] as List?) ?? const [];
    final date = DateTime.parse(day['date'] as String);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('EEEE d MMMM', 'fr_FR').format(date), style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            for (final s in slots.cast<Map<String, dynamic>>())
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Text('${(s['start_time'] as String).substring(0, 5)}  '),
                    Expanded(child: Text(s['subject_label'] as String)),
                    if (s['already_planned'] == true)
                      const Chip(
                        label: Text('déjà prévue', style: TextStyle(fontSize: 10)),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestions(BuildContext context) {
    if (_questions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final q = _questions[_questionIndex];
    final isLast = _questionIndex == _questions.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(value: (_questionIndex + 1) / _questions.length),
        const SizedBox(height: 8),
        Text('Question ${_questionIndex + 1}/${_questions.length}', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 16),
        Chip(label: Text(_questionTypeLabels[q.type] ?? q.type), visualDensity: VisualDensity.compact),
        const SizedBox(height: 8),
        Text(q.texte, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(q.pourquoi, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 20),
        Expanded(child: SingleChildScrollView(child: _buildAnswerInput(q))),
        if (q.clePreference != null)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
            value: _rememberFlags[q.id] ?? true,
            onChanged: (v) => setState(() => _rememberFlags[q.id] = v ?? true),
            title: const Text('Se souvenir de cette réponse pour les prochaines fois'),
            subtitle: const Text('L\'IA ne reposera plus cette question à l\'avenir.'),
          ),
        if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        Row(
          children: [
            TextButton(
              onPressed: _busy ? null : () => _advanceQuestion(skip: true, question: q, isLast: isLast),
              child: const Text('Passer'),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _busy ? null : () => _advanceQuestion(skip: false, question: q, isLast: isLast),
              child: _busy
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(isLast ? 'Valider' : 'Suivant'),
            ),
          ],
        ),
      ],
    );
  }

  final Map<String, TextEditingController> _answerControllers = {};
  final Map<String, Set<String>> _multiAnswers = {};

  Widget _buildAnswerInput(ClarificationQuestion q) {
    switch (q.type) {
      case 'oui_non':
        return SegmentedButton<String>(
          segments: const [ButtonSegment(value: 'oui', label: Text('Oui')), ButtonSegment(value: 'non', label: Text('Non'))],
          selected: {_answers[q.id] ?? q.reponseSuggeree ?? 'non'},
          onSelectionChanged: (s) => setState(() => _answers[q.id] = s.first),
        );
      case 'choix_unique':
        return Wrap(
          spacing: 6,
          children: (q.options ?? []).map((o) {
            return ChoiceChip(
              label: Text(o),
              selected: (_answers[q.id] ?? q.reponseSuggeree) == o,
              onSelected: (_) => setState(() => _answers[q.id] = o),
            );
          }).toList(),
        );
      case 'choix_multiple':
      case 'eleves':
      case 'notions':
        final selected = _multiAnswers.putIfAbsent(q.id, () => {});
        return Wrap(
          spacing: 6,
          children: (q.options ?? []).map((o) {
            return FilterChip(
              label: Text(o),
              selected: selected.contains(o),
              onSelected: (v) => setState(() {
                if (v) {
                  selected.add(o);
                } else {
                  selected.remove(o);
                }
                _answers[q.id] = selected.join(', ');
              }),
            );
          }).toList(),
        );
      case 'echelle':
        final value = double.tryParse(_answers[q.id] ?? '') ?? 3;
        return Slider(
          value: value, min: 1, max: 5, divisions: 4, label: value.round().toString(),
          onChanged: (v) => setState(() => _answers[q.id] = v.round().toString()),
        );
      case 'texte_court':
      default:
        final controller = _answerControllers.putIfAbsent(
          q.id, () => TextEditingController(text: _answers[q.id] ?? ''),
        );
        return TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(hintText: q.reponseSuggeree ?? '', border: const OutlineInputBorder()),
          onChanged: (v) => _answers[q.id] = v,
        );
    }
  }

  Future<void> _advanceQuestion({required bool skip, required ClarificationQuestion question, required bool isLast}) async {
    if (skip && !_answers.containsKey(question.id) && question.reponseSuggeree != null) {
      _answers[question.id] = question.reponseSuggeree!;
    }
    if (isLast) {
      await _submitAnswersAndBuildSkeleton();
    } else {
      setState(() => _questionIndex++);
    }
  }

  Widget _buildSquelette(BuildContext context) {
    final byDate = <String, List<SkeletonEntry>>{};
    for (final e in _skeleton) {
      final slot = _targetSlots.firstWhere((s) => s.index == e.creneauIndex, orElse: () => _targetSlots.first);
      byDate.putIfAbsent(slot.date, () => []).add(e);
    }
    final unplanned = _targetSlots.where((s) => !_skeleton.any((e) => e.creneauIndex == s.index)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Plan de la période', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'Vérifiez les notions choisies pour chaque créneau avant de lancer la préparation détaillée. '
          'Décochez un créneau pour ne pas le préparer cette fois.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            children: [
              for (final date in byDate.keys.toList()..sort()) ...[
                Text(
                  DateFormat('EEEE d MMMM', 'fr_FR').format(DateTime.parse(date)),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                for (final e in byDate[date]!)
                  _buildSkeletonTile(e, _targetSlots.firstWhere((s) => s.index == e.creneauIndex)),
                const SizedBox(height: 8),
              ],
              if (unplanned.isNotEmpty) ...[
                const Divider(),
                Text('Non planifiés par l\'IA', style: Theme.of(context).textTheme.labelLarge),
                for (final s in unplanned)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.remove_circle_outline),
                    title: Text(s.subjectLabel),
                    subtitle: Text('${DateFormat('EEE d/MM', 'fr_FR').format(DateTime.parse(s.date))} — aucune notion proposée'),
                  ),
              ],
            ],
          ),
        ),
        if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        Row(
          children: [
            TextButton(onPressed: _busy ? null : () => setState(() => _step = _Step.questions), child: const Text('Retour')),
            const Spacer(),
            FilledButton.icon(
              onPressed: _busy || _skeleton.isEmpty ? null : _confirmSkeletonAndStartDays,
              icon: _busy
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.auto_awesome),
              label: const Text('Lancer la génération détaillée'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSkeletonTile(SkeletonEntry e, FlatSlot slot) {
    final notionsLabel = e.notions.map((n) => '${n['code']} (${n['intent']})').join(', ');
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text('${slot.startTime.substring(0, 5)} — ${slot.subjectLabel}'),
        subtitle: Text('$notionsLabel\n${e.justification}'),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Ne pas préparer ce créneau',
          onPressed: () => setState(() => _skeleton.removeWhere((x) => x.creneauIndex == e.creneauIndex)),
        ),
      ),
    );
  }

  Widget _buildJours(BuildContext context) {
    final total = _distinctDates.length;
    final done = _doneDates.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Préparation jour par jour', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: total == 0 ? 0 : done / total),
        const SizedBox(height: 4),
        Text('$done/$total jour(s) préparé(s)', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: [
              for (final date in _distinctDates)
                ListTile(
                  leading: _dayStatusIcon(date),
                  title: Text(DateFormat('EEEE d MMMM', 'fr_FR').format(DateTime.parse(date))),
                  subtitle: _dayErrors[date] != null ? Text(_dayErrors[date]!, maxLines: 2, overflow: TextOverflow.ellipsis) : null,
                  trailing: _dayErrors[date] != null && !_busy
                      ? TextButton(onPressed: () => _generateNextDay(date), child: const Text('Réessayer'))
                      : null,
                ),
            ],
          ),
        ),
        if (_retryAt != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Limite de débit Mistral atteinte — nouvel essai automatique dans '
              '0:${_remaining.inSeconds.clamp(0, 999).toString().padLeft(2, '0')}',
              textAlign: TextAlign.center,
            ),
          ),
        if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        // Visible dès qu'au moins un jour a abouti, même si d'autres restent
        // en erreur — un jour qui échoue durablement ne doit jamais empêcher
        // de valider ce qui est déjà prêt.
        if (done > 0)
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => GenerationValidationScreen(requestId: _request!.id)),
            ),
            icon: const Icon(Icons.fact_check_outlined),
            label: Text(done == total ? 'Voir les propositions' : 'Voir les propositions ($done/$total jours prêts)'),
          ),
      ],
    );
  }

  Widget _dayStatusIcon(String date) {
    if (_doneDates.contains(date)) return const Icon(Icons.check_circle, color: AppColors.masteryAcquis);
    if (_dayErrors[date] != null) return Icon(Icons.error_outline, color: AppColors.masteryNonAcquis);
    if (_currentProcessingDate == date || (_busy && _currentProcessingDate == null)) {
      return const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2));
    }
    return const Icon(Icons.schedule);
  }

  Widget _buildTermine(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.celebration_outlined, size: 48, color: AppColors.aiProposed),
          const SizedBox(height: 16),
          Text(
            _dayErrors.isEmpty
                ? 'Préparation terminée pour ${_doneDates.length} jour(s).'
                : 'Préparation terminée, ${_dayErrors.length} jour(s) en erreur.',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => GenerationValidationScreen(requestId: _request!.id)),
            ),
            icon: const Icon(Icons.fact_check_outlined),
            label: const Text('Voir les propositions'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }
}
