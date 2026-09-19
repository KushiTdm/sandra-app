import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/result/result.dart';

class WeeklyReview {
  const WeeklyReview({
    required this.id,
    required this.weekStart,
    required this.weekEnd,
    required this.summary,
    required this.narrative,
    this.generationRequestId,
  });

  final String id;
  final DateTime weekStart;
  final DateTime weekEnd;
  final Map<String, dynamic> summary;
  final String? narrative;
  final String? generationRequestId;

  factory WeeklyReview.fromJson(Map<String, dynamic> json) => WeeklyReview(
        id: json['id'] as String,
        weekStart: DateTime.parse(json['week_start'] as String),
        weekEnd: DateTime.parse(json['week_end'] as String),
        summary: (json['summary'] as Map).cast<String, dynamic>(),
        narrative: json['narrative'] as String?,
        generationRequestId: json['generation_request_id'] as String?,
      );
}

class WeeklyReviewRateLimited implements Exception {
  WeeklyReviewRateLimited(this.retryAt);
  final DateTime retryAt;
}

/// Bilan de la semaine (§10) : le résumé (absences, comportements, sujets
/// traités, notions vues, difficultés, prévu vs réalisé) est calculé et
/// rédigé côté Edge Function (`generate-weekly-review`) ; ce repository ne
/// fait que le lire, le déclencher, et relier la génération de la semaine
/// suivante une fois lancée (§10 : "doit être proposé à l'IA").
class WeeklyReviewRepository {
  const WeeklyReviewRepository(this._client);

  final SupabaseClient _client;

  Future<WeeklyReview?> find({required String classId, required DateTime weekStart}) async {
    final rows = await _client
        .from('weekly_reviews')
        .select()
        .eq('class_id', classId)
        .eq('week_start', _isoDate(weekStart))
        .limit(1);
    if (rows.isEmpty) return null;
    return WeeklyReview.fromJson(rows.first);
  }

  Future<WeeklyReview> generate(DateTime weekStart) async {
    try {
      final res = await _client.functions.invoke('generate-weekly-review', body: {
        'week_start': _isoDate(weekStart),
      });
      final data = res.data as Map<String, dynamic>;
      return WeeklyReview.fromJson((data['weekly_review'] as Map).cast<String, dynamic>());
    } on FunctionException catch (e) {
      final data = e.details;
      if (data is Map && data['error'] == 'rate_limited') {
        throw WeeklyReviewRateLimited(DateTime.parse(data['retry_at'] as String));
      }
      throw AppException(
        data is Map && data['message'] != null ? data['message'].toString() : 'Échec de la génération du bilan.',
        e,
      );
    }
  }

  /// Relie le bilan à la génération IA de la semaine suivante, lancée depuis
  /// l'écran : `build_generation_context` retrouve ensuite ce bilan tout
  /// seul (via `week_end`), ce lien ne sert qu'à l'affichage dans l'écran.
  Future<void> linkGenerationRequest(String weeklyReviewId, String requestId) async {
    try {
      await _client
          .from('weekly_reviews')
          .update({'generation_request_id': requestId})
          .eq('id', weeklyReviewId);
    } on PostgrestException catch (e) {
      throw AppException(e.message, e);
    }
  }

  /// Existe-t-il un bilan du soir pour cette date (le vendredi de la
  /// semaine) ? Condition d'activation du bouton "Bilan de la semaine"
  /// (§10 : seulement une fois ce bilan enregistré).
  Future<bool> hasDailyReview({required String classId, required DateTime date}) async {
    final days = await _client
        .from('journal_days')
        .select('id')
        .eq('class_id', classId)
        .eq('date', _isoDate(date))
        .limit(1);
    if (days.isEmpty) return false;
    final reviews = await _client
        .from('daily_reviews')
        .select('id')
        .eq('day_id', days.first['id'] as String)
        .limit(1);
    return reviews.isNotEmpty;
  }

  static String _isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
