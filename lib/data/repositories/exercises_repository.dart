import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/result/result.dart';

/// Un exercice de la fiche. `type` vaut `application` (l'élève travaille sur
/// les `items` fournis) ou `production` (il écrit lui-même : la fiche
/// imprimée lui laisse des lignes).
class Exercice {
  const Exercice({
    required this.numero,
    required this.type,
    required this.consigne,
    required this.items,
    required this.attendu,
  });

  factory Exercice.fromJson(Map<String, dynamic> json) => Exercice(
        numero: (json['numero'] as num?)?.toInt() ?? 0,
        type: json['type'] as String? ?? 'application',
        consigne: json['consigne'] as String? ?? '',
        items: ((json['items'] as List?) ?? const []).map((e) => e.toString()).toList(),
        attendu: json['attendu'] as String? ?? '',
      );

  final int numero;
  final String type;
  final String consigne;
  final List<String> items;
  final String attendu;

  bool get isProduction => type == 'production';
}

class NiveauFiche {
  const NiveauFiche({
    required this.niveau,
    required this.titre,
    required this.aides,
    required this.exercices,
  });

  factory NiveauFiche.fromJson(Map<String, dynamic> json) => NiveauFiche(
        niveau: json['niveau'] as String? ?? '',
        titre: json['titre'] as String? ?? '',
        aides: ((json['aides'] as List?) ?? const []).map((e) => e.toString()).toList(),
        exercices: ((json['exercices'] as List?) ?? const [])
            .map((e) => Exercice.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );

  final String niveau;
  final String titre;
  final List<String> aides;
  final List<Exercice> exercices;

  /// Libellé lisible : `etayage` ne veut rien dire sur une feuille imprimée.
  String get label => switch (niveau) {
        'etayage' => 'Avec aide',
        'autonomie' => 'En autonomie',
        _ => niveau,
      };
}

class ExerciseSheet {
  const ExerciseSheet({
    required this.id,
    required this.date,
    required this.subjectLabel,
    required this.title,
    required this.objectif,
    required this.competenceBo,
    required this.consigneGenerale,
    required this.dureeMin,
    required this.materiel,
    required this.niveaux,
    required this.entryId,
    this.bilanNotes,
    this.bilanAt,
  });

  factory ExerciseSheet.fromPayload({
    required String id,
    required DateTime date,
    required String subjectLabel,
    required Map<String, dynamic> payload,
    String? entryId,
    String? bilanNotes,
    DateTime? bilanAt,
  }) =>
      ExerciseSheet(
        id: id,
        date: date,
        subjectLabel: subjectLabel,
        title: payload['titre'] as String? ?? 'Fiche d\'exercices',
        objectif: payload['objectif'] as String? ?? '',
        competenceBo: payload['competence_bo'] as String? ?? '',
        consigneGenerale: payload['consigne_generale'] as String? ?? '',
        dureeMin: (payload['duree_min'] as num?)?.toInt() ?? 0,
        materiel: ((payload['materiel'] as List?) ?? const []).map((e) => e.toString()).toList(),
        niveaux: ((payload['niveaux'] as List?) ?? const [])
            .map((e) => NiveauFiche.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        entryId: entryId,
        bilanNotes: bilanNotes,
        bilanAt: bilanAt,
      );

  final String id;
  final DateTime date;
  final String subjectLabel;
  final String title;
  final String objectif;
  final String competenceBo;
  final String consigneGenerale;
  final int dureeMin;
  final List<String> materiel;
  final List<NiveauFiche> niveaux;
  final String? entryId;

  /// Comment l'exercice s'est déroulé pour les élèves — écrit par Sandra
  /// après usage, jamais par l'IA (R1 ne s'applique pas : c'est une note de
  /// l'enseignante sur sa propre fiche, pas un contenu proposé).
  final String? bilanNotes;
  final DateTime? bilanAt;

  /// Nouvelle instance avec certains champs remplacés — pour refléter
  /// localement un changement déjà enregistré côté serveur, sans recharger
  /// toute la fiche.
  ExerciseSheet copyWith({
    DateTime? date,
    Object? entryId = _unset,
    Object? bilanNotes = _unset,
    Object? bilanAt = _unset,
  }) =>
      ExerciseSheet(
        id: id,
        date: date ?? this.date,
        subjectLabel: subjectLabel,
        title: title,
        objectif: objectif,
        competenceBo: competenceBo,
        consigneGenerale: consigneGenerale,
        dureeMin: dureeMin,
        materiel: materiel,
        niveaux: niveaux,
        entryId: identical(entryId, _unset) ? this.entryId : entryId as String?,
        bilanNotes: identical(bilanNotes, _unset) ? this.bilanNotes : bilanNotes as String?,
        bilanAt: identical(bilanAt, _unset) ? this.bilanAt : bilanAt as DateTime?,
      );
}

/// Sentinelle pour distinguer « champ non fourni » de « champ remis à null »
/// dans `copyWith` (un simple `entryId == null` ne suffirait pas : délier une
/// fiche d'une séance, c'est justement lui passer `null` explicitement).
const _unset = Object();

sealed class GenerateExercisesOutcome {}

class ExercisesGenerated extends GenerateExercisesOutcome {
  ExercisesGenerated(this.propositionId, this.payload);
  final String propositionId;
  final Map<String, dynamic> payload;
}

class ExercisesRateLimited extends GenerateExercisesOutcome {
  ExercisesRateLimited(this.retryAt);
  final DateTime retryAt;
}

class ExercisesValidationFailed extends GenerateExercisesOutcome {
  ExercisesValidationFailed(this.details);
  final List<String> details;
}

/// Fiches d'exercices sur 2 niveaux (§4, migration 0027). Comme pour les
/// séances, l'IA n'écrit que dans `ai_propositions` : la fiche n'existe
/// vraiment qu'après validation de Sandra (R1).
class ExercisesRepository {
  const ExercisesRepository(this._client);

  final SupabaseClient _client;

  /// `entryId` accompagne une séance existante (contexte le plus riche) ;
  /// `domainCode` génère une fiche autonome pour une matière choisie
  /// directement, sans passer par une séance déjà saisie — exactement l'un
  /// ou l'autre, jamais les deux (l'Edge Function les refuse ensemble).
  Future<GenerateExercisesOutcome> generate({
    String? entryId,
    String? domainCode,
    String? consigneLibre,
    int? dureeMin,
  }) async {
    assert(
      (entryId == null) != (domainCode == null),
      'generate() attend soit entryId, soit domainCode — pas les deux, pas aucun.',
    );
    try {
      final res = await _client.functions.invoke('generate-exercises', body: {
        'entry_id': ?entryId,
        'domain_code': ?domainCode,
        if (consigneLibre != null && consigneLibre.trim().isNotEmpty)
          'consigne_libre': consigneLibre.trim(),
        'duree_min': ?dureeMin,
      });
      final data = res.data as Map<String, dynamic>;
      return ExercisesGenerated(
        data['proposition_id'] as String,
        Map<String, dynamic>.from(data['payload'] as Map),
      );
    } on FunctionException catch (e) {
      final data = e.details;
      if (data is Map && data['error'] == 'rate_limited') {
        return ExercisesRateLimited(DateTime.parse(data['retry_at'] as String));
      }
      if (data is Map && data['error'] == 'validation_failed') {
        return ExercisesValidationFailed(
          ((data['details'] as List?) ?? const []).map((e) => e.toString()).toList(),
        );
      }
      throw AppException(
        data is Map && data['message'] != null
            ? data['message'].toString()
            : 'Échec de la génération des exercices.',
        e,
      );
    }
  }

  /// Valide la proposition : c'est `apply_ai_proposition()` qui crée la fiche.
  Future<String> accept(String propositionId) async {
    try {
      final ids = await _client.rpc<List<dynamic>>(
        'apply_ai_proposition',
        params: {'p_id': propositionId},
      );
      return ids.first.toString();
    } on PostgrestException catch (e) {
      throw AppException(e.message, e);
    }
  }

  Future<void> reject(String propositionId) async {
    try {
      await _client.from('ai_propositions').update({'status': 'rejetee'}).eq('id', propositionId);
    } on PostgrestException catch (e) {
      throw AppException(e.message, e);
    }
  }

  static const _selectColumns =
      'id, date, subject_label, payload, entry_id, bilan_notes, bilan_at';

  static ExerciseSheet _fromRow(Map<String, dynamic> r) => ExerciseSheet.fromPayload(
        id: r['id'] as String,
        date: DateTime.parse(r['date'] as String),
        subjectLabel: r['subject_label'] as String? ?? '',
        payload: Map<String, dynamic>.from(r['payload'] as Map),
        entryId: r['entry_id'] as String?,
        bilanNotes: r['bilan_notes'] as String?,
        bilanAt: r['bilan_at'] != null ? DateTime.parse(r['bilan_at'] as String) : null,
      );

  /// Les fiches déjà validées pour une séance, la plus récente d'abord.
  Future<List<ExerciseSheet>> sheetsForEntry(String entryId) async {
    try {
      final rows = await _client
          .from('exercise_sheets')
          .select(_selectColumns)
          .eq('entry_id', entryId)
          .order('created_at', ascending: false);
      return (rows as List).map((r) => _fromRow(Map<String, dynamic>.from(r as Map))).toList();
    } on PostgrestException catch (e) {
      throw AppException(e.message, e);
    }
  }

  Future<void> deleteSheet(String sheetId) async {
    try {
      await _client.from('exercise_sheets').delete().eq('id', sheetId);
    } on PostgrestException catch (e) {
      throw AppException(e.message, e);
    }
  }

  /// Change le jour visé et/ou la séance liée d'une fiche déjà enregistrée
  /// (demande explicite de Sandra, 16 septembre 2026 : générer un exercice
  /// puis l'enregistrer pour le lendemain, ou le lier après coup à un cours).
  /// Écriture directe, hors `ai_propositions` : c'est Sandra qui range sa
  /// propre fiche, pas l'IA qui propose un contenu (R1 ne s'applique pas).
  /// `unlinkEntry: true` délie explicitement la fiche de toute séance.
  Future<void> updateSchedule(
    String sheetId, {
    DateTime? date,
    String? entryId,
    bool unlinkEntry = false,
  }) async {
    final patch = <String, dynamic>{
      if (date != null) 'date': _isoDate(date),
      if (unlinkEntry) 'entry_id': null else 'entry_id': ?entryId,
    };
    if (patch.isEmpty) return;
    try {
      await _client.from('exercise_sheets').update(patch).eq('id', sheetId);
    } on PostgrestException catch (e) {
      throw AppException(e.message, e);
    }
  }

  /// Enregistre comment la fiche s'est déroulée pour les élèves. Un texte
  /// vide efface le bilan plutôt que d'enregistrer une note vide horodatée.
  Future<void> saveBilan(String sheetId, String notes) async {
    final trimmed = notes.trim();
    try {
      await _client.from('exercise_sheets').update({
        'bilan_notes': trimmed.isEmpty ? null : trimmed,
        'bilan_at': trimmed.isEmpty ? null : DateTime.now().toIso8601String(),
      }).eq('id', sheetId);
    } on PostgrestException catch (e) {
      throw AppException(e.message, e);
    }
  }

  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
