import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/result/result.dart';
import '../../core/supabase/supabase_bootstrap.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/assistant_repository.dart';

final assistantRepositoryProvider =
    Provider<AssistantRepository>((ref) => AssistantRepository(supabase));

/// Questions prêtes à l'emploi : évitent la page blanche et montrent
/// immédiatement ce que l'assistant sait faire.
const _suggestions = [
  'Qui était absent cette semaine ?',
  'Qu\'est-ce qui a été fait en grammaire jusqu\'ici ?',
  'Qu\'y a-t-il à l\'emploi du temps demain ?',
  'Que reste-t-il à voir en géométrie ?',
];

/// Nombre de renvois automatiques après une limite de débit. Au-delà, la main
/// revient à Sandra : mieux vaut un bouton qui l'attend qu'une application qui
/// retente indéfiniment sans qu'elle sache pourquoi.
const _maxAutoRetries = 2;

/// Assistant conversationnel (§11) : Sandra pose ses questions en langage
/// naturel, l'assistant va chercher la réponse dans les vraies données de la
/// classe (absences, cahier journal, EDT, programme) et cite les sources
/// qu'il a consultées.
class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<AssistantMessage> _messages = [];
  bool _thinking = false;
  String? _error;

  /// Instant avant lequel Mistral refuse un nouvel appel. Tant qu'il est dans
  /// le futur, l'envoi est impossible et un décompte l'annonce : c'est plus
  /// clair qu'un message d'erreur rouge sur une réponse qui ne viendra pas.
  DateTime? _cooldownUntil;
  Timer? _cooldownTicker;

  /// Question à renvoyer seule dès que le débit repart.
  String? _queuedQuestion;
  int _autoRetries = 0;

  bool get _cooling => _remaining > Duration.zero;

  Duration get _remaining {
    final until = _cooldownUntil;
    if (until == null) return Duration.zero;
    final left = until.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  /// « 0:03 » — la seconde entamée est comptée, pour ne jamais afficher 0
  /// pendant que l'envoi est encore bloqué.
  String get _remainingLabel {
    final seconds = (_remaining.inMilliseconds / 1000).ceil();
    return '0:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _cooldownTicker?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startCooldown(DateTime until, {String? queued}) {
    _cooldownTicker?.cancel();
    setState(() {
      _cooldownUntil = until;
      _queuedQuestion = queued;
      _error = null;
    });
    // 200 ms plutôt qu'une seconde : le décompte reste fluide et arrive à zéro
    // sans décalage visible avec le moment où l'envoi redevient possible.
    _cooldownTicker = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!mounted) return timer.cancel();
      if (_cooling) return setState(() {});
      timer.cancel();
      final pending = _queuedQuestion;
      setState(() {
        _cooldownUntil = null;
        _queuedQuestion = null;
      });
      if (pending != null && _autoRetries < _maxAutoRetries) {
        _autoRetries++;
        _ask(pending, alreadyInThread: true);
      }
    });
  }

  /// Signature compatible `ValueChanged<String>` pour les suggestions.
  Future<void> _send([String? preset]) =>
      _ask(preset ?? _controller.text, alreadyInThread: false);

  Future<void> _ask(String raw, {required bool alreadyInThread}) async {
    final question = raw.trim();
    if (question.isEmpty || _thinking || _cooling) return;

    setState(() {
      if (!alreadyInThread) {
        _messages.add(AssistantMessage(role: 'user', content: question));
        _controller.clear();
      }
      _thinking = true;
      _error = null;
    });
    _scrollToEnd();

    try {
      final outcome = await ref.read(assistantRepositoryProvider).ask(
            question: question,
            // L'historique sans la question en cours, déjà dans le fil.
            history: _messages.isEmpty
                ? const []
                : _messages.sublist(0, _messages.length - 1),
          );
      if (!mounted) return;
      switch (outcome) {
        case AssistantAnswer(:final message):
          setState(() {
            _messages.add(message);
            _autoRetries = 0;
          });
        case AssistantRateLimited(:final retryAt):
          // La question reste dans le fil et repart toute seule : Sandra n'a
          // rien à ressaisir ni à retenter.
          _startCooldown(retryAt, queued: question);
      }
    } on AppException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _thinking = false);
      _scrollToEnd();
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final blocked = _thinking || _cooling;
    // Le fil et le composeur ne montrent jamais d'attente en double : pendant
    // le compte à rebours, c'est le décompte qui fait foi.
    final trailing = _cooling ? 1 : (_thinking ? 1 : 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant'),
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              tooltip: 'Nouvelle conversation',
              icon: const Icon(Icons.refresh),
              onPressed: blocked
                  ? null
                  : () => setState(() {
                        _messages.clear();
                        _error = null;
                      }),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _EmptyConversation(onPick: blocked ? null : _send)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    itemCount: _messages.length + trailing,
                    itemBuilder: (context, index) {
                      if (index >= _messages.length) {
                        return _cooling
                            ? _WaitingBubble(
                                label: _queuedQuestion == null
                                    ? 'Limite de débit — attente $_remainingLabel'
                                    : 'Limite de débit atteinte — je relance dans $_remainingLabel',
                              )
                            : const _WaitingBubble(label: 'Je consulte vos données…');
                      }
                      return _MessageBubble(message: _messages[index]);
                    },
                  ),
          ),
          _Composer(
            controller: _controller,
            error: _error,
            thinking: _thinking,
            cooling: _cooling,
            remainingLabel: _remainingLabel,
            onSend: () => _send(),
          ),
        ],
      ),
    );
  }
}

/// Barre de saisie : champ + bouton d'envoi, posés sur une surface opaque
/// séparée du fil par un filet, pour qu'elle se lise comme une barre et non
/// comme un bloc sombre au bas de l'écran.
class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.error,
    required this.thinking,
    required this.cooling,
    required this.remainingLabel,
    required this.onSend,
  });

  final TextEditingController controller;
  final String? error;
  final bool thinking;
  final bool cooling;
  final String remainingLabel;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final blocked = thinking || cooling;

    return Material(
      color: scheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(height: 1, thickness: 1, color: scheme.outlineVariant.withValues(alpha: 0.5)),
          if (error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline, size: 16, color: scheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error!,
                      style: TextStyle(color: scheme.error, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          if (cooling)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Icon(Icons.hourglass_bottom, size: 16, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Quota de l\'IA atteint — envoi possible dans $remainingLabel',
                      style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      enabled: !blocked,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => onSend(),
                      decoration: InputDecoration(
                        hintText: cooling
                            ? 'Envoi possible dans $remainingLabel…'
                            : 'Posez une question sur votre classe…',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Taille fixe : sans elle, le bouton hériterait de la
                  // largeur minimale du thème et écraserait le champ de saisie
                  // (voir app_theme.dart).
                  SizedBox(
                    height: 48,
                    width: 48,
                    child: FilledButton(
                      onPressed: blocked ? null : onSend,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(48, 48),
                        padding: EdgeInsets.zero,
                        shape: const CircleBorder(),
                        backgroundColor: AppColors.aiProposed,
                        disabledBackgroundColor:
                            scheme.onSurface.withValues(alpha: 0.12),
                      ),
                      child: _sendButtonChild(scheme),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sendButtonChild(ColorScheme scheme) {
    if (cooling) {
      return Text(
        remainingLabel.substring(2),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: scheme.onSurfaceVariant,
        ),
      );
    }
    if (thinking) {
      return const SizedBox(
        height: 18,
        width: 18,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    }
    return const Icon(Icons.send, size: 18, color: Colors.white);
  }
}

class _EmptyConversation extends StatelessWidget {
  const _EmptyConversation({required this.onPick});

  /// `null` pendant une attente : les suggestions ne doivent pas permettre de
  /// contourner le blocage du composeur.
  final ValueChanged<String>? onPick;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      children: [
        Center(
          child: Image.asset(
            'assets/branding/icon_assistant.png',
            width: 56,
            color: AppColors.aiProposed,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Assistant IA',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 6),
        Text(
          'Absences, cahier journal, emploi du temps, avancement du programme : '
          'les réponses viennent de vos données réelles, jamais d\'une invention.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 20),
        for (final s in _suggestions)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton(
              onPressed: onPick == null ? null : () => onPick!(s),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.north_east, size: 14),
                  const SizedBox(width: 10),
                  Expanded(child: Text(s, textAlign: TextAlign.left)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final AssistantMessage message;

  /// Le prompt (assistant_logic.ts) demande du Markdown pour les réponses à
  /// plusieurs volets — titres `##`, `**gras**`, listes `- ` — rendu ici tel
  /// quel plutôt qu'affiché avec ses caractères de balisage. `MarkdownBody`
  /// et non `Markdown` : pas de défilement propre, la bulle épouse son
  /// contenu comme le ferait un `Text`.
  static Widget _body(BuildContext context, String content) {
    final theme = Theme.of(context);
    final base = theme.textTheme.bodyMedium ?? const TextStyle();
    return MarkdownBody(
      data: content,
      selectable: true,
      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
        p: base,
        listBullet: base,
        strong: base.copyWith(fontWeight: FontWeight.w700),
        em: base.copyWith(fontStyle: FontStyle.italic),
        h2: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        h3: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        blockSpacing: 8,
        listIndent: 16,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final scheme = Theme.of(context).colorScheme;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.82),
        decoration: BoxDecoration(
          color: isUser
              ? scheme.primaryContainer
              : AppColors.aiProposed.withValues(alpha: 0.12),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _body(context, message.content),
            if (message.tools.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: message.tools
                    .map((t) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.aiProposed.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            t,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.aiProposed,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Bulle d'attente : réflexion en cours, ou décompte avant reprise.
class _WaitingBubble extends StatelessWidget {
  const _WaitingBubble({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.aiProposed.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 14,
              width: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.aiProposed),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(label, style: Theme.of(context).textTheme.bodySmall),
            ),
          ],
        ),
      ),
    );
  }
}
