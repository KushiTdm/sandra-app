import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../data/repositories/edt_repository.dart';
import '../../models/schedule_slot.dart';
import 'edt_pdf_export.dart';
import 'edt_providers.dart';
import 'new_version_screen.dart';
import 'slot_editor_sheet.dart';

const _days = [1, 2, 3, 4, 5];
const _dayLabels = {1: 'Lun', 2: 'Mar', 3: 'Mer', 4: 'Jeu', 5: 'Ven'};

class EdtScreen extends ConsumerWidget {
  const EdtScreen({super.key});

  Future<void> _exportPdf(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final version = await ref.read(currentVersionProvider.future);
      final slots = await ref.read(currentSlotsProvider.future);
      if (!context.mounted) return;
      await exportEdtToPdf(
        context,
        slots: slots,
        versionLabel: '${version.label} — en vigueur depuis le ${DateFormat('dd/MM/yyyy').format(version.validFrom)}',
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Échec de l\'export PDF : $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: _days.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Emploi du temps'),
          bottom: TabBar(
            tabs: _days.map((d) => Tab(text: _dayLabels[d])).toList(),
          ),
          actions: [
            IconButton(
              tooltip: 'Exporter en PDF',
              icon: const Icon(Icons.picture_as_pdf_outlined),
              onPressed: () => _exportPdf(context, ref),
            ),
            IconButton(
              tooltip: 'Nouvelle version à partir d\'une date',
              icon: const Icon(Icons.history_edu_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NewVersionScreen()),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            const _RelocateBanner(),
            const _VersionLabel(),
            Expanded(
              child: TabBarView(
                children: _days.map((d) => _DaySlotList(dayOfWeek: d)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VersionLabel extends ConsumerWidget {
  const _VersionLabel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(currentVersionProvider);
    return version.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (v) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: Theme.of(context).colorScheme.outline),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${v.label} — en vigueur depuis le ${DateFormat('dd/MM/yyyy').format(v.validFrom)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RelocateBanner extends ConsumerWidget {
  const _RelocateBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(entriesToRelocateProvider).value ?? const <EntryToRelocate>[];
    if (entries.isEmpty) return const SizedBox.shrink();

    return MaterialBanner(
      backgroundColor: AppColors.masteryFragile.withValues(alpha: 0.15),
      leading: const Icon(Icons.warning_amber_outlined, color: AppColors.masteryFragile),
      content: Text(
        '${entries.length} séance${entries.length > 1 ? 's' : ''} à replacer suite au changement '
        'd\'emploi du temps : ${entries.map((e) => '${DateFormat('dd/MM').format(e.date)} ${e.subjectLabel}').join(', ')}',
      ),
      actions: [
        TextButton(
          onPressed: () => ref.invalidate(entriesToRelocateProvider),
          child: const Text('Actualiser'),
        ),
      ],
    );
  }
}

class _DaySlotList extends ConsumerWidget {
  const _DaySlotList({required this.dayOfWeek});

  final int dayOfWeek;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slots = ref.watch(currentSlotsProvider);
    final version = ref.watch(currentVersionProvider).value;

    return slots.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Erreur : $error')),
      data: (all) {
        final dayList = all.where((s) => s.dayOfWeek == dayOfWeek).toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime));

        return Stack(
          children: [
            ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
              itemCount: dayList.length,
              separatorBuilder: (_, _) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final slot = dayList[index];
                return _EditableSlotCard(
                  slot: slot,
                  onTap: version == null
                      ? null
                      : () => showSlotEditorSheet(
                            context,
                            versionId: version.id,
                            dayOfWeek: dayOfWeek,
                            slot: slot,
                          ),
                );
              },
            ),
            if (version != null)
              Positioned(
                right: 12,
                bottom: 12,
                child: FloatingActionButton(
                  heroTag: 'add_slot_$dayOfWeek',
                  onPressed: () => showSlotEditorSheet(
                    context,
                    versionId: version.id,
                    dayOfWeek: dayOfWeek,
                  ),
                  child: const Icon(Icons.add),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _EditableSlotCard extends StatelessWidget {
  const _EditableSlotCard({required this.slot, this.onTap});

  final ScheduleSlot slot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (slot.isBreak) {
      return Card(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        margin: EdgeInsets.zero,
        child: ListTile(
          dense: true,
          onTap: onTap,
          leading: Text(_timeRange, style: Theme.of(context).textTheme.bodySmall),
          title: Text(slot.subjectLabel, style: Theme.of(context).textTheme.bodySmall),
        ),
      );
    }

    final isSpecialist = slot.taughtBy == 'specialist';
    final color = subjectColorFor(slot.subjectLabel).color;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 4,
          decoration: BoxDecoration(
            color: isSpecialist ? AppColors.masteryNonVu : color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text('${slot.subjectLabel}${slot.groupLabel != null ? ' — Groupe ${slot.groupLabel}' : ''}'),
        subtitle: Text([
          _timeRange,
          if (isSpecialist) 'Spécialiste',
          if (slot.domainCode != null) slot.domainCode!,
        ].join(' · ')),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  String get _timeRange => '${slot.startTime.substring(0, 5)}–${slot.endTime.substring(0, 5)}';
}
