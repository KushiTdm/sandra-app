import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/result/result.dart';

sealed class GenerateLessonOutcome {}

class GenerateLessonSuccess extends GenerateLessonOutcome {
  GenerateLessonSuccess(this.propositionId, this.payload);
  final String propositionId;
  final Map<String, dynamic> payload;
}

class GenerateLessonRateLimited extends GenerateLessonOutcome {
  GenerateLessonRateLimited(this.retryAt);
  final DateTime retryAt;
}

class GenerateLessonValidationFailed extends GenerateLessonOutcome {
  GenerateLessonValidationFailed(this.details);
  final List<String> details;
}

/// Appelle l'Edge Function `generate-lesson` (§9.1-9.3, création ou
/// correction) et gère la boîte de validation (`apply_ai_proposition`,
/// §6.7) — jamais d'écriture directe dans journal_entries depuis le client
/// (R1). CRUD complet sur une séance générée : `generateLesson` (créer),
/// `correctLesson` (demander une correction ciblée par l'IA — la
/// modification manuelle et la suppression n'ont pas besoin de méthode
/// dédiée, l'éditeur structuré et `JournalRepository.deleteEntry` du Lot 3
/// marchent déjà pour toute séance quelle que soit son origine).
class AiRepository {
  const AiRepository(this._client);

  final SupabaseClient _client;

  Future<GenerateLessonOutcome> generateLesson({
    required String slotId,
    required DateTime date,
    String? consigneLibre,
  }) {
    final iso = _isoDate(date);
    return _invoke({
      'slot_id': slotId,
      'date': iso,
      if (consigneLibre != null) 'consigne_libre': consigneLibre,
    });
  }

  Future<GenerateLessonOutcome> correctLesson({
    required String entryId,
    required String correctionInstruction,
  }) {
    return _invoke({
      'entry_id': entryId,
      'correction_instruction': correctionInstruction,
    });
  }

  Future<GenerateLessonOutcome> _invoke(Map<String, dynamic> body) async {
    try {
      final res = await _client.functions.invoke('generate-lesson', body: body);
      final data = res.data as Map<String, dynamic>;
      return GenerateLessonSuccess(data['proposition_id'] as String, data['payload'] as Map<String, dynamic>);
    } on FunctionException catch (e) {
      final data = e.details;
      if (data is Map && data['error'] == 'rate_limited') {
        return GenerateLessonRateLimited(DateTime.parse(data['retry_at'] as String));
      }
      if (data is Map && data['error'] == 'validation_failed') {
        return GenerateLessonValidationFailed(
          (data['details'] as List).map((e) => e.toString()).toList(),
        );
      }
      throw AppException(
        data is Map && data['message'] != null ? data['message'].toString() : 'Échec de la génération IA.',
        e,
      );
    }
  }

  Future<void> applyProposition(String propositionId) async {
    try {
      await _client.rpc<void>('apply_ai_proposition', params: {'p_id': propositionId});
    } on PostgrestException catch (e) {
      throw AppException(e.message, e);
    }
  }

  Future<void> rejectProposition(String propositionId) async {
    try {
      await _client.from('ai_propositions').update({'status': 'rejetee'}).eq('id', propositionId);
    } on PostgrestException catch (e) {
      throw AppException(e.message, e);
    }
  }

  static String _isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
