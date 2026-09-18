import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/result/result.dart';
import '../../models/schedule_slot.dart';

class EntryToRelocate {
  const EntryToRelocate({
    required this.entryId,
    required this.date,
    required this.subjectLabel,
    this.groupLabel,
    this.title,
  });

  final String entryId;
  final DateTime date;
  final String subjectLabel;
  final String? groupLabel;
  final String? title;

  factory EntryToRelocate.fromJson(Map<String, dynamic> json) => EntryToRelocate(
    entryId: json['entry_id'] as String,
    date: DateTime.parse(json['date'] as String),
    subjectLabel: json['subject_label'] as String,
    groupLabel: json['group_label'] as String?,
    title: json['title'] as String?,
  );
}

/// Un domaine du référentiel avec son intitulé lisible (`curriculum_domains`)
/// — les écrans ne doivent jamais afficher un code brut type `FR.CNJ` à
/// Sandra, qui n'a aucune raison de connaître ces abréviations.
class CurriculumDomain {
  const CurriculumDomain({required this.code, required this.subject, required this.label});

  final String code;
  final String subject; // FR, MA, QLM, EMC, EPS
  final String label;

  factory CurriculumDomain.fromJson(Map<String, dynamic> json) => CurriculumDomain(
    code: json['code'] as String,
    subject: json['subject'] as String,
    label: json['label'] as String,
  );

  static const _subjectLabels = {
    'FR': 'Français',
    'MA': 'Mathématiques',
    'QLM': 'Questionner le monde',
    'EMC': 'Enseignement moral et civique',
    'EPS': 'Éducation physique et sportive',
  };

  String get subjectLabel => _subjectLabels[subject] ?? subject;

  /// « Français · Grammaire — Se repérer dans la phrase simple »
  String get fullLabel => '$subjectLabel · $label';
}

/// Toutes les écritures de l'EDT passent par les fonctions Postgres du §3.5
/// (`save_schedule_slot`, `delete_schedule_slot`, `create_schedule_version`) :
/// le contrôle de chevauchement et la réconciliation des séances déjà
/// prévues vivent en base, pas ici, pour ne jamais pouvoir être contournés.
class EdtRepository {
  const EdtRepository(this._client);

  final SupabaseClient _client;

  Future<String> currentClassId() async {
    final rows = await _client.from('classes').select('id').limit(1);
    if (rows.isEmpty) throw const AppException('Aucune classe associée à ce compte.');
    return rows.first['id'] as String;
  }

  Future<({String id, String label, DateTime validFrom})> currentVersion(String classId) async {
    final rows = await _client
        .from('schedule_versions')
        .select('id, label, valid_from')
        .eq('class_id', classId)
        .isFilter('valid_to', null)
        .limit(1);
    if (rows.isEmpty) {
      throw const AppException('Aucun emploi du temps en vigueur pour cette classe.');
    }
    final row = rows.first;
    return (
      id: row['id'] as String,
      label: row['label'] as String,
      validFrom: DateTime.parse(row['valid_from'] as String),
    );
  }

  Future<List<ScheduleSlot>> slotsForVersion(String versionId) async {
    final rows = await _client
        .from('schedule_slots')
        .select()
        .eq('version_id', versionId)
        .order('day_of_week')
        .order('start_time');
    return rows.map(ScheduleSlot.fromJson).toList();
  }

  Future<String> saveSlot({
    required String? slotId,
    required String versionId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    required String subjectLabel,
    String? domainCode,
    String? groupLabel,
    required String taughtBy,
    required bool isBreak,
  }) async {
    try {
      final result = await _client.rpc<String>('save_schedule_slot', params: {
        'p_slot_id': slotId,
        'p_version_id': versionId,
        'p_day_of_week': dayOfWeek,
        'p_start_time': startTime,
        'p_end_time': endTime,
        'p_subject_label': subjectLabel,
        'p_domain_code': domainCode,
        'p_group_label': groupLabel,
        'p_taught_by': taughtBy,
        'p_is_break': isBreak,
      });
      return result;
    } on PostgrestException catch (e) {
      throw AppException(e.message, e);
    }
  }

  Future<void> deleteSlot(String slotId) async {
    try {
      await _client.rpc<void>('delete_schedule_slot', params: {'p_slot_id': slotId});
    } on PostgrestException catch (e) {
      throw AppException(e.message, e);
    }
  }

  Future<String> createVersion({
    required String classId,
    required DateTime validFrom,
    required String label,
    required List<Map<String, dynamic>> slots,
  }) async {
    try {
      final iso = '${validFrom.year.toString().padLeft(4, '0')}-'
          '${validFrom.month.toString().padLeft(2, '0')}-'
          '${validFrom.day.toString().padLeft(2, '0')}';
      final result = await _client.rpc<String>('create_schedule_version', params: {
        'p_class_id': classId,
        'p_valid_from': iso,
        'p_label': label,
        'p_slots': slots,
      });
      return result;
    } on PostgrestException catch (e) {
      throw AppException(e.message, e);
    }
  }

  Future<List<EntryToRelocate>> entriesToRelocate() async {
    final rows = await _client
        .from('v_entries_to_relocate')
        .select()
        .order('date');
    return rows.map(EntryToRelocate.fromJson).toList();
  }

  Future<List<String>> knownDomainCodes(String classId) async {
    final rows = await _client
        .from('subject_domain_map')
        .select('domain_code')
        .eq('class_id', classId);
    final codes = rows.map((r) => r['domain_code'] as String).toSet().toList();
    codes.sort();
    return codes;
  }

  /// Les mêmes domaines, mais avec leur intitulé lisible, groupés par matière.
  Future<List<CurriculumDomain>> knownDomains(String classId) async {
    final codes = await knownDomainCodes(classId);
    if (codes.isEmpty) return const [];
    final rows = await _client
        .from('curriculum_domains')
        .select('code, subject, label')
        .inFilter('code', codes);
    final domains = rows.map(CurriculumDomain.fromJson).toList();
    // Français, Maths, QLM, EMC, EPS — l'ordre dans lequel Sandra les cite.
    const subjectOrder = ['FR', 'MA', 'QLM', 'EMC', 'EPS'];
    domains.sort((a, b) {
      final bySubject = subjectOrder.indexOf(a.subject).compareTo(subjectOrder.indexOf(b.subject));
      return bySubject != 0 ? bySubject : a.label.compareTo(b.label);
    });
    return domains;
  }
}
