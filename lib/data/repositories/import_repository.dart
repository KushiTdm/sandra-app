import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/result/result.dart';
import '../../core/supabase/supabase_bootstrap.dart';

/// Partagé entre l'import de cahier journal (Réglages) et l'ajout/correction
/// d'exercices par photo (Journal) : un seul provider pour tout upload vers
/// le bucket `imports`.
final importRepositoryProvider = Provider<ImportRepository>((ref) => ImportRepository(supabase));

/// Import d'une page de cahier journal (§8.2) : photo (OCR + structuration
/// IA) ou JSON collé directement — les deux voies passent par la même Edge
/// Function `import-journal` et produisent des `ai_propositions` ordinaires,
/// validables séance par séance comme n'importe quelle génération IA.
class ImportRepository {
  const ImportRepository(this._client);

  final SupabaseClient _client;

  /// Dépose la photo dans le bucket privé `imports` (chemin
  /// `{class_id}/...` — RLS via `storage_owns_class_path`, voir 0012_storage)
  /// et renvoie le chemin de l'objet, à transmettre tel quel à l'Edge
  /// Function (jamais l'URL : elle génère elle-même une URL signée à durée
  /// de vie courte pour l'appel OCR).
  Future<String> uploadPhoto({
    required String classId,
    required String category, // 'journal' | 'exercices'
    required File file,
  }) async {
    final ext = file.path.split('.').last.toLowerCase();
    final path = '$classId/$category/${const Uuid().v4()}.$ext';
    try {
      await _client.storage.from('imports').upload(path, file);
      return path;
    } on StorageException catch (e) {
      throw AppException(e.message, e);
    }
  }

  Future<List<Map<String, dynamic>>> importJournalPhoto({
    required DateTime date,
    required String storagePath,
  }) async {
    final data = await _invoke({'mode': 'photo', 'date': _isoDate(date), 'storage_path': storagePath});
    return ((data['propositions'] as List?) ?? const []).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> importJournalJson({
    required DateTime date,
    required List<Map<String, dynamic>> entries,
  }) async {
    final data = await _invoke({'mode': 'json', 'date': _isoDate(date), 'entries': entries});
    return ((data['propositions'] as List?) ?? const []).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> _invoke(Map<String, dynamic> body) async {
    try {
      final res = await _client.functions.invoke('import-journal', body: body);
      return res.data as Map<String, dynamic>;
    } on FunctionException catch (e) {
      final data = e.details;
      if (data is Map && data['error'] == 'rate_limited') {
        throw ImportRateLimited(DateTime.parse(data['retry_at'] as String));
      }
      if (data is Map && data['error'] == 'validation_failed') {
        throw ImportValidationFailed(
          ((data['details'] as List?) ?? const []).map((e) => e.toString()).toList(),
        );
      }
      throw AppException(
        data is Map && data['message'] != null ? data['message'].toString() : 'Échec de l\'import.',
        e,
      );
    }
  }

  static String _isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

class ImportRateLimited implements Exception {
  ImportRateLimited(this.retryAt);
  final DateTime retryAt;
}

class ImportValidationFailed implements Exception {
  ImportValidationFailed(this.details);
  final List<String> details;
}
