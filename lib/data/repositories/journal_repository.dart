import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/result/result.dart';
import '../../models/journal_entry.dart';

class NotionOption {
  const NotionOption({required this.code, required this.label});
  final String code;
  final String label;
}

class EntryNotionLink {
  const EntryNotionLink({required this.notionCode, required this.intent});
  final String notionCode;
  final String intent;
}

/// Écritures directes (pas de fonction dédiée comme pour l'EDT) : la saisie
/// manuelle n'a pas de logique de contrôle comparable au chevauchement/
/// réconciliation de l'emploi du temps — la RLS suffit à protéger l'accès.
/// Le suivi de version (`journal_entry_revisions`) est automatique, par
/// trigger (§0007) : rien à faire ici pour ça.
class JournalRepository {
  const JournalRepository(this._client);

  final SupabaseClient _client;

  Future<String> currentClassId() async {
    final rows = await _client.from('classes').select('id').limit(1);
    if (rows.isEmpty) throw const AppException('Aucune classe associée à ce compte.');
    return rows.first['id'] as String;
  }

  static String isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// Lecture seule : id du `journal_days` s'il existe déjà, sinon `null`.
  /// N'écrit jamais rien — voir `ensureDay` pour la version qui crée.
  Future<String?> findDayId(String classId, DateTime date) async {
    final rows = await _client
        .from('journal_days')
        .select('id')
        .eq('class_id', classId)
        .eq('date', isoDate(date))
        .limit(1);
    return rows.isEmpty ? null : rows.first['id'] as String;
  }

  /// Renvoie l'id du `journal_days` pour cette date, en le créant si besoin.
  /// N'appeler qu'au moment où Sandra confirme réellement une action (ex. :
  /// enregistrer une nouvelle séance) — jamais depuis un simple affichage,
  /// pour ne pas créer des journées vides rien qu'en consultant le calendrier.
  Future<String> ensureDay(String classId, DateTime date) async {
    final existing = await findDayId(classId, date);
    if (existing != null) return existing;

    final created = await _client
        .from('journal_days')
        .insert({'class_id': classId, 'date': isoDate(date), 'status': 'brouillon'})
        .select('id')
        .single();
    return created['id'] as String;
  }

  Future<List<JournalEntry>> entriesForDay(String dayId) async {
    final rows = await _client
        .from('journal_entries')
        .select()
        .eq('day_id', dayId)
        .order('start_time');
    return rows.map(JournalEntry.fromJson).toList();
  }

  Future<JournalEntry> createEntry({
    required String dayId,
    String? slotId,
    String? startTime,
    String? endTime,
    required String subjectLabel,
    String? domainCode,
    String? groupLabel,
    String? title,
    String? competenceBo,
    String? objective,
    List<String> steps = const [],
    String? differenciation,
    List<String> materiel = const [],
    String status = 'prevue',
  }) async {
    try {
      final row = await _client
          .from('journal_entries')
          .insert({
            'day_id': dayId,
            'slot_id': slotId,
            'start_time': startTime,
            'end_time': endTime,
            'subject_label': subjectLabel,
            'domain_code': domainCode,
            'group_label': groupLabel,
            'title': title,
            'competence_bo': competenceBo,
            'objective': objective,
            'deroulement_steps': steps,
            'differenciation': differenciation,
            'materiel': materiel,
            'status': status,
            'origin': 'manuel',
          })
          .select()
          .single();
      return JournalEntry.fromJson(row);
    } on PostgrestException catch (e) {
      throw AppException(e.message, e);
    }
  }

  Future<JournalEntry> updateEntry(
    String entryId, {
    required String subjectLabel,
    String? domainCode,
    String? groupLabel,
    String? title,
    String? competenceBo,
    String? objective,
    List<String> steps = const [],
    String? differenciation,
    List<String> materiel = const [],
    required String status,
  }) async {
    try {
      final row = await _client
          .from('journal_entries')
          .update({
            'subject_label': subjectLabel,
            'domain_code': domainCode,
            'group_label': groupLabel,
            'title': title,
            'competence_bo': competenceBo,
            'objective': objective,
            'deroulement_steps': steps,
            'differenciation': differenciation,
            'materiel': materiel,
            'status': status,
          })
          .eq('id', entryId)
          .select()
          .single();
      return JournalEntry.fromJson(row);
    } on PostgrestException catch (e) {
      throw AppException(e.message, e);
    }
  }

  Future<void> deleteEntry(String entryId) async {
    try {
      await _client.from('journal_entries').delete().eq('id', entryId);
    } on PostgrestException catch (e) {
      throw AppException(e.message, e);
    }
  }

  /// Fil chronologique d'un domaine sur toute la classe (§8.3, vue Par matière).
  Future<List<({JournalEntry entry, DateTime date})>> entriesForDomain(
    String classId,
    String domainCode,
  ) async {
    final rows = await _client
        .from('journal_entries')
        .select('*, journal_days!inner(class_id, date)')
        .eq('domain_code', domainCode)
        .eq('journal_days.class_id', classId)
        .order('date', referencedTable: 'journal_days');
    return rows
        .map((row) => (
              entry: JournalEntry.fromJson(row),
              date: DateTime.parse((row['journal_days'] as Map<String, dynamic>)['date'] as String),
            ))
        .toList();
  }

  Future<List<NotionOption>> notionsForDomain(String domainCode) async {
    final rows = await _client
        .from('curriculum_notions')
        .select('code, label')
        .eq('domain_code', domainCode)
        .order('code');
    return rows.map((r) => NotionOption(code: r['code'] as String, label: r['label'] as String)).toList();
  }

  Future<List<EntryNotionLink>> entryNotions(String entryId) async {
    final rows = await _client
        .from('journal_entry_notions')
        .select('notion_code, intent')
        .eq('entry_id', entryId);
    return rows
        .map((r) => EntryNotionLink(notionCode: r['notion_code'] as String, intent: r['intent'] as String))
        .toList();
  }

  Future<void> setEntryNotions(String entryId, List<EntryNotionLink> links) async {
    await _client.from('journal_entry_notions').delete().eq('entry_id', entryId);
    if (links.isEmpty) return;
    await _client.from('journal_entry_notions').insert(
          links
              .map((l) => {'entry_id': entryId, 'notion_code': l.notionCode, 'intent': l.intent})
              .toList(),
        );
  }
}
