import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/result/result.dart';

class AppFeedback {
  const AppFeedback({
    required this.id,
    required this.category,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String category; // 'bug' | 'idee' | 'autre'
  final String body;
  final DateTime createdAt;

  factory AppFeedback.fromJson(Map<String, dynamic> json) => AppFeedback(
        id: json['id'] as String,
        category: json['category'] as String,
        body: json['body'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

/// Section "Commentaires" (Plus) : un journal de remarques de Sandra sur
/// l'application — pas une donnée métier critique, donc accès direct en
/// ligne (pas de local-first Drift, contrairement à vie_de_classe).
class FeedbackRepository {
  const FeedbackRepository(this._client);

  final SupabaseClient _client;

  Future<List<AppFeedback>> list(String classId) async {
    try {
      final rows = await _client
          .from('app_feedback')
          .select()
          .eq('class_id', classId)
          .order('created_at', ascending: false);
      return rows.map(AppFeedback.fromJson).toList();
    } on PostgrestException catch (e) {
      throw AppException(e.message, e);
    }
  }

  Future<void> add({required String classId, required String category, required String body}) async {
    try {
      await _client.from('app_feedback').insert({
        'class_id': classId,
        'teacher_id': _client.auth.currentUser!.id,
        'category': category,
        'body': body,
      });
    } on PostgrestException catch (e) {
      throw AppException(e.message, e);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _client.from('app_feedback').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw AppException(e.message, e);
    }
  }
}
