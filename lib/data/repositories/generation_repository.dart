import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/result/result.dart';

class GenerationRequest {
  const GenerationRequest({
    required this.id,
    required this.classId,
    required this.scope,
    required this.dateFrom,
    required this.dateTo,
    required this.regenerateExisting,
    required this.status,
    required this.contextPack,
    required this.questions,
    required this.answers,
    required this.skeleton,
    required this.processedDates,
    required this.dayErrors,
    this.currentDay,
    this.retryAt,
  });

  final String id;
  final String classId;
  final String scope; // 'jour' | 'semaine'
  final DateTime dateFrom;
  final DateTime dateTo;
  final bool regenerateExisting;
  final String status;
  final Map<String, dynamic> contextPack;
  final List<dynamic> questions;
  final Map<String, dynamic> answers;
  final List<dynamic> skeleton;
  final List<String> processedDates;
  final Map<String, dynamic> dayErrors;
  final DateTime? currentDay;
  final DateTime? retryAt;

  factory GenerationRequest.fromJson(Map<String, dynamic> json) => GenerationRequest(
        id: json['id'] as String,
        classId: json['class_id'] as String,
        scope: json['scope'] as String,
        dateFrom: DateTime.parse(json['date_from'] as String),
        dateTo: DateTime.parse(json['date_to'] as String),
        regenerateExisting: json['regenerate_existing'] as bool? ?? false,
        status: json['status'] as String,
        contextPack: (json['context_pack'] as Map?)?.cast<String, dynamic>() ?? const {},
        questions: (json['questions'] as List?) ?? const [],
        answers: (json['answers'] as Map?)?.cast<String, dynamic>() ?? const {},
        skeleton: (json['skeleton'] as List?) ?? const [],
        processedDates: ((json['processed_dates'] as List?) ?? const []).cast<String>(),
        dayErrors: (json['day_errors'] as Map?)?.cast<String, dynamic>() ?? const {},
        currentDay: json['current_day'] != null ? DateTime.parse(json['current_day'] as String) : null,
        retryAt: json['retry_at'] != null ? DateTime.parse(json['retry_at'] as String) : null,
      );
}

/// Un créneau ciblé, aplati et indexé (même logique que
/// generate-journal/journal_logic.ts::flattenTargetSlots — les deux doivent
/// rester des jumelles strictes, l'index sert de référence stable entre le
/// squelette et le détail jour par jour). Exclut par défaut les créneaux déjà
/// pourvus d'une séance, sauf si [regenerateExisting] est vrai (§9.5).
class FlatSlot {
  const FlatSlot({
    required this.index,
    required this.date,
    required this.slotId,
    required this.startTime,
    required this.endTime,
    required this.subjectLabel,
    this.domainCode,
    this.groupLabel,
    required this.alreadyPlanned,
  });

  final int index;
  final String date;
  final String slotId;
  final String startTime;
  final String endTime;
  final String subjectLabel;
  final String? domainCode;
  final String? groupLabel;
  final bool alreadyPlanned;
}

List<FlatSlot> flattenTargetSlots(Map<String, dynamic> contextPack, bool regenerateExisting) {
  final flat = <FlatSlot>[];
  final cible = (contextPack['cible'] as List?) ?? const [];
  for (final day in cible) {
    final date = day['date'] as String;
    final slots = (day['slots'] as List?) ?? const [];
    for (final slot in slots) {
      final alreadyPlanned = slot['already_planned'] as bool? ?? false;
      if (!regenerateExisting && alreadyPlanned) continue;
      flat.add(FlatSlot(
        index: flat.length,
        date: date,
        slotId: slot['slot_id'] as String,
        startTime: slot['start_time'] as String,
        endTime: slot['end_time'] as String,
        subjectLabel: slot['subject_label'] as String,
        domainCode: slot['domain_code'] as String?,
        groupLabel: slot['group_label'] as String?,
        alreadyPlanned: alreadyPlanned,
      ));
    }
  }
  return flat;
}

class ClarificationQuestion {
  const ClarificationQuestion({
    required this.id,
    required this.texte,
    required this.pourquoi,
    required this.type,
    this.options,
    this.reponseSuggeree,
    this.clePreference,
  });

  final String id;
  final String texte;
  final String pourquoi;
  final String type;
  final List<String>? options;
  final String? reponseSuggeree;

  /// Non nul quand l'IA juge que la réponse est une décision durable (§9.7) —
  /// proposée à l'enregistrement dans `teacher_preferences` sous cette clé,
  /// pour ne plus jamais reposer la même question à une future génération.
  final String? clePreference;

  factory ClarificationQuestion.fromJson(Map<String, dynamic> json) => ClarificationQuestion(
        id: json['id'] as String,
        texte: json['texte'] as String,
        pourquoi: json['pourquoi'] as String,
        type: json['type'] as String,
        options: (json['options'] as List?)?.cast<String>(),
        reponseSuggeree: json['reponse_suggeree'] as String?,
        clePreference: json['cle_preference'] as String?,
      );
}

class SkeletonEntry {
  const SkeletonEntry({required this.creneauIndex, required this.notions, required this.justification});

  final int creneauIndex;
  final List<Map<String, dynamic>> notions; // [{code, intent}]
  final String justification;

  factory SkeletonEntry.fromJson(Map<String, dynamic> json) => SkeletonEntry(
        creneauIndex: json['creneau_index'] as int,
        notions: ((json['notions'] as List?) ?? const []).cast<Map<String, dynamic>>(),
        justification: json['justification'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'creneau_index': creneauIndex, 'notions': notions, 'justification': justification};
}

/// Une décision pédagogique durable mémorisée depuis le wizard (§9.7) —
/// propre à l'enseignante (RLS `teacher_id = auth.uid()`), pas à la classe :
/// chaque compte garde ses propres habitudes de préparation.
class TeacherPreference {
  const TeacherPreference({required this.key, required this.value, required this.source, required this.updatedAt});

  final String key;
  final dynamic value;
  final String source; // 'wizard' | 'manuel'
  final DateTime updatedAt;

  factory TeacherPreference.fromJson(Map<String, dynamic> json) => TeacherPreference(
        key: json['key'] as String,
        value: json['value'],
        source: json['source'] as String,
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  /// Le modèle choisit des clés en snake_case pour rester stable d'une
  /// génération à l'autre (voir le prompt) — affiché en clair pour Sandra.
  String get label => key.replaceAll('_', ' ');
}

sealed class DayGenerationOutcome {}

class DayGenerationSuccess extends DayGenerationOutcome {
  DayGenerationSuccess({required this.propositionsCreated, required this.requestStatus, required this.nextDate});
  final int propositionsCreated;
  final String requestStatus;
  final String? nextDate;
}

class DayGenerationRateLimited extends DayGenerationOutcome {
  DayGenerationRateLimited(this.retryAt);
  final DateTime retryAt;
}

class DayGenerationValidationFailed extends DayGenerationOutcome {
  DayGenerationValidationFailed({required this.details, required this.requestStatus, required this.nextDate});
  final List<String> details;
  final String requestStatus;
  final String? nextDate;
}

/// Génération du cahier journal par l'IA pour un jour ou une semaine
/// (§9.5-9.9). Le contexte (`build_generation_context`) est du SQL pur, lu et
/// stocké directement par l'app avant le premier appel à `generate-journal` —
/// pas besoin d'Edge Function pour cette phase (R4 : aucune clé n'est requise
/// côté serveur pour de la lecture SQL). `generate-journal` ne fait que les 3
/// appels qui ont vraiment besoin de Mistral (questions, squelette, détail
/// jour par jour), un à la fois, l'état vivant dans `generation_requests`
/// pour reprendre une génération interrompue exactement où elle s'est
/// arrêtée.
class GenerationRepository {
  const GenerationRepository(this._client);

  final SupabaseClient _client;

  static String isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  Future<Map<String, dynamic>> buildContext({
    required String classId,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    try {
      final result = await _client.rpc<Map<String, dynamic>>('build_generation_context', params: {
        'p_class_id': classId,
        'p_date_from': isoDate(dateFrom),
        'p_date_to': isoDate(dateTo),
      });
      return result;
    } on PostgrestException catch (e) {
      throw AppException(e.message, e);
    }
  }

  Future<GenerationRequest> createRequest({
    required String classId,
    required String scope,
    required DateTime dateFrom,
    required DateTime dateTo,
    required bool regenerateExisting,
    required Map<String, dynamic> contextPack,
  }) async {
    try {
      final row = await _client
          .from('generation_requests')
          .insert({
            'class_id': classId,
            'scope': scope,
            'date_from': isoDate(dateFrom),
            'date_to': isoDate(dateTo),
            'regenerate_existing': regenerateExisting,
            'context_pack': contextPack,
            'created_by': _client.auth.currentUser!.id,
          })
          .select()
          .single();
      return GenerationRequest.fromJson(row);
    } on PostgrestException catch (e) {
      throw AppException(e.message, e);
    }
  }

  Future<GenerationRequest> loadRequest(String id) async {
    final row = await _client.from('generation_requests').select().eq('id', id).single();
    return GenerationRequest.fromJson(row);
  }

  /// Pour proposer une reprise à l'ouverture de l'écran : la dernière
  /// génération non terminée de cette classe, s'il y en a une.
  Future<GenerationRequest?> findResumableRequest(String classId) async {
    final rows = await _client
        .from('generation_requests')
        .select()
        .eq('class_id', classId)
        .neq('status', 'termine')
        .order('created_at', ascending: false)
        .limit(1);
    if (rows.isEmpty) return null;
    return GenerationRequest.fromJson(rows.first);
  }

  Future<void> saveAnswers(String requestId, Map<String, dynamic> answers) async {
    try {
      await _client.from('generation_requests').update({'answers': answers}).eq('id', requestId);
    } on PostgrestException catch (e) {
      throw AppException(e.message, e);
    }
  }

  Future<void> saveSkeleton(String requestId, List<SkeletonEntry> skeleton) async {
    try {
      await _client
          .from('generation_requests')
          .update({'skeleton': skeleton.map((e) => e.toJson()).toList()}).eq('id', requestId);
    } on PostgrestException catch (e) {
      throw AppException(e.message, e);
    }
  }

  Future<List<ClarificationQuestion>> requestQuestions(String requestId) async {
    final data = await _invoke({'request_id': requestId, 'action': 'questions'});
    return ((data['questions'] as List?) ?? const [])
        .cast<Map<String, dynamic>>()
        .map(ClarificationQuestion.fromJson)
        .toList();
  }

  Future<List<SkeletonEntry>> requestSkeleton(String requestId) async {
    final data = await _invoke({'request_id': requestId, 'action': 'skeleton'});
    return ((data['plan'] as List?) ?? const []).cast<Map<String, dynamic>>().map(SkeletonEntry.fromJson).toList();
  }

  Future<DayGenerationOutcome> generateDay(String requestId, DateTime date) async {
    try {
      final data = await _invoke({'request_id': requestId, 'action': 'day', 'date': isoDate(date)});
      return DayGenerationSuccess(
        propositionsCreated: data['propositions_created'] as int,
        requestStatus: data['request_status'] as String,
        nextDate: data['next_date'] as String?,
      );
    } on _RateLimited catch (e) {
      return DayGenerationRateLimited(e.retryAt);
    } on _ValidationFailed catch (e) {
      return DayGenerationValidationFailed(
        details: e.details,
        requestStatus: e.requestStatus,
        nextDate: e.nextDate,
      );
    }
  }

  /// Propositions déjà générées pour cette demande (boîte de validation,
  /// §9.6 phase 4) — les mêmes lignes `ai_propositions` que pour une séance
  /// isolée, `apply_ai_proposition`/`AiRepository` s'appliquent sans
  /// modification (R1).
  Future<List<Map<String, dynamic>>> propositionsForRequest(String requestId) async {
    return await _client
        .from('ai_propositions')
        .select('id, target_date, status, payload, scope')
        .eq('generation_request_id', requestId)
        .order('target_date');
  }

  // --- Préférences durables (§9.7) ----------------------------------------

  /// Mémorise une réponse durable du wizard sous [key] (proposée par l'IA via
  /// `ClarificationQuestion.clePreference`) — `upsert` sur `(teacher_id,
  /// key)` : répondre à nouveau à la même question met simplement à jour la
  /// préférence existante plutôt que d'en accumuler une deuxième.
  Future<void> savePreference({required String key, required dynamic value, String source = 'wizard'}) async {
    try {
      await _client.from('teacher_preferences').upsert({
        'teacher_id': _client.auth.currentUser!.id,
        'key': key,
        'value': value,
        'source': source,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'teacher_id,key');
    } on PostgrestException catch (e) {
      throw AppException(e.message, e);
    }
  }

  /// Toutes les préférences de l'enseignante connectée, les plus récemment
  /// mises à jour d'abord — pour l'écran « Préférences de génération IA »
  /// (Réglages), où Sandra peut voir ce que l'IA a retenu et l'oublier.
  Future<List<TeacherPreference>> listPreferences() async {
    final rows = await _client.from('teacher_preferences').select().order('updated_at', ascending: false);
    return rows.map(TeacherPreference.fromJson).toList();
  }

  Future<void> deletePreference(String key) async {
    try {
      await _client.from('teacher_preferences').delete().eq('key', key);
    } on PostgrestException catch (e) {
      throw AppException(e.message, e);
    }
  }

  Future<Map<String, dynamic>> _invoke(Map<String, dynamic> body) async {
    try {
      final res = await _client.functions.invoke('generate-journal', body: body);
      return res.data as Map<String, dynamic>;
    } on FunctionException catch (e) {
      final data = e.details;
      if (data is Map && data['error'] == 'rate_limited') {
        throw _RateLimited(DateTime.parse(data['retry_at'] as String));
      }
      if (data is Map && data['error'] == 'validation_failed') {
        throw _ValidationFailed(
          details: (data['details'] as List).map((e) => e.toString()).toList(),
          requestStatus: data['request_status'] as String? ?? 'en_cours',
          nextDate: data['next_date'] as String?,
        );
      }
      throw AppException(
        data is Map && data['message'] != null ? data['message'].toString() : 'Échec de la génération IA.',
        e,
      );
    }
  }
}

class _RateLimited implements Exception {
  _RateLimited(this.retryAt);
  final DateTime retryAt;
}

class _ValidationFailed implements Exception {
  _ValidationFailed({required this.details, required this.requestStatus, required this.nextDate});
  final List<String> details;
  final String requestStatus;
  final String? nextDate;
}
