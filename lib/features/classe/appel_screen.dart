import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/result/result.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/repositories/vie_de_classe_repository.dart';
import '../../models/student.dart';
import 'vie_de_classe_providers.dart';

const _statusLabels = {
  'present': 'Présent',
  'absent': 'Absent',
  'retard': 'Retard',
  'excuse': 'Excusé',
};
const _statusIcons = {
  'present': Icons.check,
  'absent': Icons.close,
  'retard': Icons.schedule,
  'excuse': Icons.mail_outline,
};
const _statusColors = {
  'present': AppColors.masteryAcquis,
  'absent': AppColors.masteryNonAcquis,
  'retard': AppColors.masteryFragile,
  'excuse': AppColors.masteryEnCours,
};

/// Appel (§6.3, Lot 4) : accessible à tout moment depuis l'app (pas
/// seulement au créneau nominal), rapide — toute la classe est
/// pré-considérée présente, Sandra ne touche que les exceptions.
///
/// Mise en page : le nom occupe sa propre ligne, les 4 statuts la ligne
/// suivante. Le premier essai les mettait dans le `trailing` d'un `ListTile`,
/// qui réservait toute la largeur aux boutons et écrasait le nom sur une
/// colonne d'une lettre de large (constaté en conditions réelles).
class AppelScreen extends ConsumerStatefulWidget {
  const AppelScreen({super.key, this.initialDate});

  final DateTime? initialDate;

  @override
  ConsumerState<AppelScreen> createState() => _AppelScreenState();
}

class _AppelScreenState extends ConsumerState<AppelScreen> {
  late DateTime _date;
  /// `journee` enregistre matin **et** après-midi d'un coup : une absence est
  /// le plus souvent sur la journée entière, c'est le cas par défaut.
  late String _mode;
  final Map<String, ({String status, String? reason})> _exceptions = {};
  bool _saving = false;
  bool _loadedExisting = false;

  List<String> get _halfDaysToSave =>
      _mode == 'journee' ? const ['matin', 'apres_midi'] : [_mode];

  String get _readHalfDay => _mode == 'apres_midi' ? 'apres_midi' : 'matin';

  @override
  void initState() {
    super.initState();
    final base = widget.initialDate ?? DateTime.now();
    _date = DateTime(base.year, base.month, base.day);
    _mode = 'journee';
  }

  void _loadExisting(List<AttendanceRecord> records) {
    if (_loadedExisting) return;
    _loadedExisting = true;
    for (final r in records) {
      if (r.status != 'present') {
        _exceptions[r.studentId] = (status: r.status, reason: r.reason);
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _date = DateTime(picked.year, picked.month, picked.day);
        _exceptions.clear();
        _loadedExisting = false;
      });
    }
  }

  void _setStatus(String studentId, String status) {
    setState(() {
      if (status == 'present') {
        _exceptions.remove(studentId);
      } else {
        _exceptions[studentId] = (status: status, reason: _exceptions[studentId]?.reason);
      }
    });
  }

  Future<void> _save(List<Student> students) async {
    setState(() => _saving = true);
    try {
      final repo = ref.read(vieDeClasseRepositoryProvider);
      var allSynced = true;
      for (final halfDay in _halfDaysToSave) {
        final synced = await repo.saveAttendance(
          date: _date,
          halfDay: halfDay,
          allStudentIds: students.map((s) => s.id).toList(),
          exceptions: _exceptions,
        );
        if (!synced) allSynced = false;
      }
      ref.invalidate(attendanceForProvider);
      if (!mounted) return;
      final quoi = _mode == 'journee' ? 'la journée' : (_mode == 'matin' ? 'le matin' : 'l\'après-midi');
      final base = _exceptions.isEmpty
          ? 'Appel enregistré pour $quoi — classe entière présente.'
          : 'Appel enregistré pour $quoi — ${_exceptions.length} exception(s).';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(allSynced ? base : '$base (en attente de réseau)')),
      );
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Échec : ${e.message}')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final students = ref.watch(studentsProvider);
    final attendance = ref.watch(attendanceForProvider((date: _date, halfDay: _readHalfDay)));
    final absentsCount = _exceptions.values.where((e) => e.status != 'present').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appel'),
        actions: [
          IconButton(
            tooltip: 'Choisir une date',
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: _pickDate,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                Text(
                  DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(_date),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 10),
                SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: 'journee', label: Text('Journée')),
                    ButtonSegment(value: 'matin', label: Text('Matin')),
                    ButtonSegment(value: 'apres_midi', label: Text('Après-midi')),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (s) => setState(() {
                    _mode = s.first;
                    _exceptions.clear();
                    _loadedExisting = false;
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  absentsCount == 0
                      ? 'Tout le monde est présent — touchez un élève seulement s\'il manque.'
                      : '$absentsCount élève(s) signalé(s) absent, en retard ou excusé.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: students.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur : $e')),
              data: (studentList) {
                attendance.whenData(_loadExisting);
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
                  itemCount: studentList.length,
                  itemBuilder: (context, index) {
                    final student = studentList[index];
                    final status = _exceptions[student.id]?.status ?? 'present';
                    return _StudentAttendanceCard(
                      student: student,
                      status: status,
                      onStatusChanged: (s) => _setStatus(student.id, s),
                    );
                  },
                );
              },
            ),
          ),
          // Pas de SafeArea seule : cet écran est empilé dans le Navigator de
          // l'onglet Classe, donc affiché derrière la barre de navigation
          // flottante de l'app (AppShell, extendBody: true) — SafeArea ne
          // protège que des marges système, pas de cette barre. Voir
          // AppSpacing.bottomNavClearance.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, AppSpacing.bottomNavClearance),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving || !students.hasValue ? null : () => _save(students.value!),
                  icon: _saving
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.check),
                  label: Text(
                    absentsCount == 0
                        ? 'Enregistrer — classe complète'
                        : 'Enregistrer — $absentsCount exception${absentsCount > 1 ? 's' : ''}',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentAttendanceCard extends StatelessWidget {
  const _StudentAttendanceCard({
    required this.student,
    required this.status,
    required this.onStatusChanged,
  });

  final Student student;
  final String status;
  final ValueChanged<String> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final isException = status != 'present';
    final accent = _statusColors[status]!;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: isException ? BorderSide(color: accent, width: 1.5) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    student.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
                if (student.groupLabel != null)
                  Text(
                    'Groupe ${student.groupLabel}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: _statusLabels.entries.map((entry) {
                final selected = status == entry.key;
                final color = _statusColors[entry.key]!;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _StatusButton(
                      label: entry.value,
                      icon: _statusIcons[entry.key]!,
                      color: color,
                      selected: selected,
                      onTap: () => onStatusChanged(entry.key),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  const _StatusButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurfaceVariant;
    return Material(
      color: selected ? color.withValues(alpha: 0.22) : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? color : onSurface.withValues(alpha: 0.25),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: selected ? color : onSurface),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? color : onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
