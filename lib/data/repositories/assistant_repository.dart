import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/result/result.dart';

class AssistantMessage {
  const AssistantMessage({
    required this.role,
    required this.content,
    this.tools = const [],
  });

  final String role; // 'user' | 'assistant'
  final String content;

  /// Les outils que l'assistant a réellement consultés pour répondre — affichés
  /// sous la réponse pour que Sandra sache sur quelles données elle s'appuie
  /// (R5 : aucune affirmation sur la classe sans passer par un outil).
  final List<String> tools;
}

sealed class AssistantOutcome {}

class AssistantAnswer extends AssistantOutcome {
  AssistantAnswer(this.message);
  final AssistantMessage message;
}

class AssistantRateLimited extends AssistantOutcome {
  AssistantRateLimited(this.retryAt);
  final DateTime retryAt;
}

/// Assistant conversationnel (§11) : pose la question à `assistant-chat`, qui
/// interroge la base via un catalogue fermé d'outils avec le JWT de Sandra
/// (R4) et renvoie une réponse déjà « dépseudonymisée » (vrais prénoms).
class AssistantRepository {
  const AssistantRepository(this._client);

  final SupabaseClient _client;

  static const _toolLabels = {
    'eleves_absents': 'Absences',
    'seances_du_jour': 'Cahier journal du jour',
    'emploi_du_temps': 'Emploi du temps',
    'progression_domaine': 'Avancement du programme',
    'liste_domaines': 'Domaines du programme',
    'liste_eleves': 'Liste des élèves',
    'signalements': 'Signalements',
  };

  Future<AssistantOutcome> ask({
    required String question,
    required List<AssistantMessage> history,
  }) async {
    final now = DateTime.now();
    final today = '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    try {
      final res = await _client.functions.invoke('assistant-chat', body: {
        'question': question,
        'today': today,
        'history': history.map((m) => {'role': m.role, 'content': m.content}).toList(),
      });
      final data = res.data as Map<String, dynamic>;
      final tools = ((data['tools'] as List?) ?? const [])
          .map((t) => _toolLabels[(t as Map)['outil']] ?? (t)['outil'].toString())
          .toSet()
          .toList();
      return AssistantAnswer(
        AssistantMessage(
          role: 'assistant',
          content: data['answer'] as String? ?? '',
          tools: tools,
        ),
      );
    } on FunctionException catch (e) {
      final data = e.details;
      if (data is Map && data['error'] == 'rate_limited') {
        return AssistantRateLimited(DateTime.parse(data['retry_at'] as String));
      }
      throw AppException(
        data is Map && data['message'] != null
            ? data['message'].toString()
            : 'L\'assistant n\'a pas pu répondre.',
        e,
      );
    }
  }
}
