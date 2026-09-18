import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import 'journal_providers.dart';

/// Vue Semaine (§8.3) : complétude de chaque jour, glisser vers la semaine
/// suivante/précédente, tap pour ouvrir la vue Jour correspondante.
class SemaineJournalView extends ConsumerWidget {
  const SemaineJournalView({
    super.key,
    required this.classId,
    required this.weekStart,
    required this.onWeekChanged,
    required this.onDaySelected,
  });

  final String classId;
  final DateTime weekStart;
  final ValueChanged<DateTime> onWeekChanged;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekEnd = weekStart.add(const Duration(days: 4));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => onWeekChanged(weekStart.subtract(const Duration(days: 7))),
              ),
              Text(
                'Semaine du ${DateFormat('dd/MM').format(weekStart)} au ${DateFormat('dd/MM').format(weekEnd)}',
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => onWeekChanged(weekStart.add(const Duration(days: 7))),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: List.generate(5, (i) => weekStart.add(Duration(days: i)))
                .map((date) => _DayRow(date: date, onTap: () => onDaySelected(date)))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _DayRow extends ConsumerWidget {
  const _DayRow({required this.date, required this.onTap});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nonTeaching = ref.watch(isNonTeachingDayForDateProvider(date)).value ?? false;
    final schedule = ref.watch(scheduleForDateProvider(date)).value ?? const [];
    final journal = ref.watch(dayJournalProvider(date)).value;
    final entries = journal?.entries ?? const [];

    final teachingSlots = schedule.where((s) => !s.isBreak && s.taughtBy == 'me').length;
    final done = entries.where((e) => e.status == 'faite').length;

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        onTap: onTap,
        title: Text(_capitalize(DateFormat('EEEE d MMMM', 'fr_FR').format(date))),
        subtitle: nonTeaching
            ? const Text('Pas de classe')
            : teachingSlots == 0
                ? const Text('Aucun créneau')
                : Text('$done / $teachingSlots séance${teachingSlots > 1 ? 's' : ''} faite${done > 1 ? 's' : ''}'),
        trailing: nonTeaching || teachingSlots == 0
            ? null
            : CircleAvatar(
                radius: 14,
                backgroundColor: done == teachingSlots
                    ? AppColors.masteryAcquis.withValues(alpha: 0.2)
                    : AppColors.masteryEnCours.withValues(alpha: 0.2),
                child: Text(
                  '$done/$teachingSlots',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
      ),
    );
  }

  static String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
