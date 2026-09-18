import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../classe/appel_screen.dart';
import '../classe/bilan_soir_screen.dart';
import '../journal/day_journal_view.dart';
import '../journal/journal_providers.dart';
import 'aujourdhui_providers.dart';

class AujourdhuiScreen extends ConsumerWidget {
  const AujourdhuiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(selectedDateProvider);
    final dateFormat = DateFormat('EEEE d MMMM', 'fr_FR');
    final classId = ref.watch(journalClassIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_capitalize(dateFormat.format(date))),
        actions: [
          IconButton(
            tooltip: 'Faire l\'appel',
            icon: const Icon(Icons.fact_check_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => AppelScreen(initialDate: date)),
            ),
          ),
          classId.maybeWhen(
            data: (id) => IconButton(
              tooltip: 'Bilan du soir',
              icon: const Icon(Icons.nightlight_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BilanSoirScreen(classId: id, date: date),
                ),
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          IconButton(
            tooltip: 'Aujourd\'hui',
            icon: const Icon(Icons.today_outlined),
            onPressed: () =>
                ref.read(selectedDateProvider.notifier).goToToday(),
          ),
        ],
      ),
      body: Column(
        children: [
          _DateNavigator(date: date),
          const Divider(height: 1),
          Expanded(
            child: classId.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur : $e')),
              data: (id) => DayJournalView(classId: id, date: date),
            ),
          ),
        ],
      ),
    );
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _DateNavigator extends ConsumerWidget {
  const _DateNavigator({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void shift(int days) =>
        ref.read(selectedDateProvider.notifier).shiftBy(days);
    final isToday = DateUtils.isSameDay(date, DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _NavArrow(icon: Icons.chevron_left, onTap: () => shift(-1)),
          const SizedBox(width: AppSpacing.sm),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isToday
                  ? AppColors.accent.withValues(alpha: 0.14)
                  : Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppRadius.chip),
            ),
            child: Text(
              DateFormat('dd/MM/yyyy').format(date),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: isToday ? AppColors.accent : null,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _NavArrow(icon: Icons.chevron_right, onTap: () => shift(1)),
        ],
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  const _NavArrow({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest
          .withValues(alpha: 0.5),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 22),
        ),
      ),
    );
  }
}
