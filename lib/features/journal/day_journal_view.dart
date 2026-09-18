import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/entrance_animation.dart';
import '../../core/widgets/subject_badge.dart';
import '../../models/journal_entry.dart';
import '../../models/schedule_slot.dart';
import 'ai_generation_sheet.dart';
import 'entry_editor_sheet.dart';
import 'exercices/exercices_generation_sheet.dart';
import 'exercices/exercices_list_sheet.dart';
import 'journal_providers.dart';

/// Comment une séance se présente dans les écrans d'exercices : c'est le
/// repère de Sandra pour savoir de quelle séance vient une fiche.
String _seanceLabel(JournalEntry entry) => [
      entry.subjectLabel,
      if (entry.title?.isNotEmpty ?? false) entry.title!,
    ].join(' · ');

/// Vue Jour du cahier journal (§8.3), réutilisée par l'onglet Aujourd'hui et
/// par l'onglet Journal (n'importe quelle date). Combine l'EDT du jour
/// (`get_schedule_for_date`) et les séances déjà saisies.
///
/// Important : le cahier journal réel de Sandra ne calque pas toujours l'EDT
/// créneau par créneau — une même case d'EDT peut être scindée en plusieurs
/// séances loguées (ex. « Appel » puis « Vocabulaire » à 08:30), et certaines
/// séances tombent à un horaire qui ne correspond à aucun créneau nominal.
/// Un appariement strict 1-pour-1 par horaire ferait donc disparaître des
/// séances réelles de l'écran (et du PDF) sans avertissement. La règle ici :
/// **toute séance saisie est toujours affichée** ; un créneau EDT n'est
/// affiché comme « à créer » que s'il ne chevauche aucune séance existante.
class DayJournalView extends ConsumerWidget {
  const DayJournalView({super.key, required this.classId, required this.date});

  final String classId;
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nonTeaching = ref.watch(isNonTeachingDayForDateProvider(date));

    return nonTeaching.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          _InfoBanner(icon: Icons.error_outline, text: 'Erreur : $error'),
      data: (isNonTeaching) {
        if (isNonTeaching) {
          return const _InfoBanner(
            icon: Icons.event_busy_outlined,
            text: 'Pas de classe ce jour (jour férié ou fermeture exceptionnelle).',
            showClassroom: true,
          );
        }
        if (date.weekday > DateTime.friday) {
          return const _InfoBanner(
            icon: Icons.weekend_outlined,
            text: 'Pas de classe le week-end.',
            showClassroom: true,
          );
        }
        return _ScheduleAndEntries(classId: classId, date: date);
      },
    );
  }
}

sealed class _TimelineItem {
  String get sortKey;
}

class _EntryItem extends _TimelineItem {
  _EntryItem(this.entry);
  final JournalEntry entry;
  @override
  String get sortKey => entry.startTime ?? '99:99';
}

class _EmptySlotItem extends _TimelineItem {
  _EmptySlotItem(this.slot);
  final ScheduleSlot slot;
  @override
  String get sortKey => slot.startTime;
}

class _BreakItem extends _TimelineItem {
  _BreakItem(this.slot);
  final ScheduleSlot slot;
  @override
  String get sortKey => slot.startTime;
}

/// Début de la pause déjeuner (§3.2) : sépare matin et après-midi.
const _lunchBoundary = '11:45';

bool _overlaps(String aStart, String aEnd, String bStart, String bEnd) =>
    aStart.compareTo(bEnd) < 0 && bStart.compareTo(aEnd) < 0;

class _ScheduleAndEntries extends ConsumerWidget {
  const _ScheduleAndEntries({required this.classId, required this.date});

  final String classId;
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedule = ref.watch(scheduleForDateProvider(date));
    final journal = ref.watch(dayJournalProvider(date));

    return schedule.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          _InfoBanner(icon: Icons.error_outline, text: 'Erreur : $error'),
      data: (slots) {
        final entries = journal.value?.entries ?? const <JournalEntry>[];
        final teachingSlots = slots
            .where((s) => !s.isBreak && s.taughtBy == 'me')
            .toList();

        if (slots.isEmpty && entries.isEmpty) {
          return const _InfoBanner(
            icon: Icons.calendar_month_outlined,
            text: 'Aucun emploi du temps enregistré pour ce jour.',
          );
        }

        final sorted = <_TimelineItem>[
          for (final e in entries) _EntryItem(e),
          for (final s in teachingSlots)
            if (!entries.any(
              (e) =>
                  e.startTime != null &&
                  e.endTime != null &&
                  _overlaps(e.startTime!, e.endTime!, s.startTime, s.endTime),
            ))
              _EmptySlotItem(s),
          for (final s in slots.where((s) => s.isBreak)) _BreakItem(s),
        ]..sort((a, b) => a.sortKey.compareTo(b.sortKey));

        // Deux sections courtes (matin / après-midi), séparées par la pause
        // déjeuner, se lisent bien mieux qu'une seule longue liste d'un bloc —
        // et les récréations donnent son rythme réel à la journée.
        final morning = sorted
            .where((i) => i.sortKey.compareTo(_lunchBoundary) < 0)
            .toList();
        final afternoon = sorted
            .where((i) => i.sortKey.compareTo(_lunchBoundary) >= 0)
            .toList();

        var animationIndex = 0;

        Widget buildItem(_TimelineItem item) => switch (item) {
          _EntryItem(:final entry) => _EntryCard(
            entry: entry,
            onTap: () => showEntryEditorSheet(
              context,
              classId: classId,
              date: date,
              // Modification : le rattachement au créneau (slot_id) n'est
              // pas ré-écrit par updateEntry, inutile de le transmettre ici.
              subjectLabel: entry.subjectLabel,
              domainCode: entry.domainCode,
              groupLabel: entry.groupLabel,
              startTime: entry.startTime,
              endTime: entry.endTime,
              initial: entry,
            ),
            onRequestCorrection: () => showAiCorrectionSheet(
              context,
              entryId: entry.id,
              date: date,
            ),
            onGenerateExercices: () => showExercicesGenerationSheet(
              context,
              entryId: entry.id,
              seanceLabel: _seanceLabel(entry),
              seanceDate: date,
            ),
            onShowExercices: () => showExercicesListSheet(
              context,
              entryId: entry.id,
              seanceLabel: _seanceLabel(entry),
              seanceDate: date,
            ),
          ),
          _EmptySlotItem(:final slot) => _EmptySlotCard(
            slot: slot,
            onTap: () => showEntryEditorSheet(
              context,
              classId: classId,
              date: date,
              slotId: slot.id,
              startTime: slot.startTime,
              endTime: slot.endTime,
              subjectLabel: slot.subjectLabel,
              domainCode: slot.domainCode,
              groupLabel: slot.groupLabel,
            ),
            onGenerate: slot.domainCode == null
                ? null
                : () => showAiGenerationSheet(
                    context,
                    slotId: slot.id,
                    date: date,
                  ),
          ),
          _BreakItem(:final slot) => _BreakRow(slot: slot),
        };

        List<Widget> section(String label, IconData icon, List<_TimelineItem> items) {
          if (items.isEmpty) return const [];
          final seances = items.where((i) => i is! _BreakItem).length;
          return [
            _DayPartHeader(label: label, icon: icon, seanceCount: seances),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: EntranceAnimation(
                  index: animationIndex++,
                  child: buildItem(item),
                ),
              ),
          ];
        }

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(dayJournalProvider(date));
                ref.invalidate(scheduleForDateProvider(date));
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, AppSpacing.bottomNavClearance),
                children: [
                  ...section('Matin', Icons.wb_twilight_outlined, morning),
                  ...section('Après-midi', Icons.wb_sunny_outlined, afternoon),
                ],
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: FloatingActionButton.extended(
                onPressed: () => showEntryEditorSheet(
                  context,
                  classId: classId,
                  date: date,
                  subjectLabel: '',
                ),
                icon: const Icon(Icons.add),
                label: const Text('Séance libre'),
              ),
            ),
          ],
        );
      },
    );
  }
}

const _statusIcons = {
  'faite': Icons.check_circle_outline,
  'partielle': Icons.incomplete_circle_outlined,
  'reportee': Icons.update_outlined,
  'annulee': Icons.cancel_outlined,
  'prevue': Icons.edit_note_outlined,
};

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.entry,
    required this.onTap,
    required this.onRequestCorrection,
    required this.onGenerateExercices,
    required this.onShowExercices,
  });

  final JournalEntry entry;
  final VoidCallback onTap;
  final VoidCallback onRequestCorrection;
  final VoidCallback onGenerateExercices;
  final VoidCallback onShowExercices;

  @override
  Widget build(BuildContext context) {
    final subject = subjectColorFor(entry.subjectLabel);
    final isAiProposed = entry.origin == 'ia' && entry.status == 'prevue';

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: isAiProposed
            ? const BorderSide(color: AppColors.aiProposed, width: 1.4)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              _TimeGutter(start: entry.startTime, end: entry.endTime),
              SubjectBadge(subject: subject),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${entry.subjectLabel}${entry.groupLabel != null ? ' — Groupe ${entry.groupLabel}' : ''}',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isAiProposed) ...[
                          const SizedBox(width: 6),
                          const _AiBadge(),
                        ],
                      ],
                    ),
                    if (entry.title?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 2),
                      Text(
                        entry.title!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                _statusIcons[entry.status] ?? Icons.circle_outlined,
                size: 20,
                color: entry.status == 'faite' ? AppColors.masteryAcquis : null,
              ),
              _EntryAiMenu(
                onRequestCorrection: onRequestCorrection,
                onGenerateExercices: onGenerateExercices,
                onShowExercices: onShowExercices,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Les actions IA d'une séance, regroupées : un seul bouton sur la carte,
/// qui reste lisible, plutôt qu'une rangée d'icônes concurrentes.
class _EntryAiMenu extends StatelessWidget {
  const _EntryAiMenu({
    required this.onRequestCorrection,
    required this.onGenerateExercices,
    required this.onShowExercices,
  });

  final VoidCallback onRequestCorrection;
  final VoidCallback onGenerateExercices;
  final VoidCallback onShowExercices;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<VoidCallback>(
      tooltip: 'Actions IA',
      icon: const Icon(Icons.auto_awesome, color: AppColors.aiProposed),
      onSelected: (action) => action(),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: onGenerateExercices,
          child: const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.assignment_outlined),
            title: Text('Générer des exercices'),
            subtitle: Text('2 niveaux, à imprimer'),
          ),
        ),
        PopupMenuItem(
          value: onShowExercices,
          child: const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.folder_open_outlined),
            title: Text('Fiches d\'exercices'),
            subtitle: Text('Celles déjà enregistrées'),
          ),
        ),
        PopupMenuItem(
          value: onRequestCorrection,
          child: const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.edit_note_outlined),
            title: Text('Corriger la séance'),
            subtitle: Text('Demander une reprise à l\'IA'),
          ),
        ),
      ],
    );
  }
}

class _AiBadge extends StatelessWidget {
  const _AiBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.aiProposed.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: const Text(
        'Proposé par l\'IA',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.aiProposed,
        ),
      ),
    );
  }
}

class _EmptySlotCard extends StatelessWidget {
  const _EmptySlotCard({
    required this.slot,
    required this.onTap,
    this.onGenerate,
  });

  final ScheduleSlot slot;
  final VoidCallback onTap;
  final VoidCallback? onGenerate;

  @override
  Widget build(BuildContext context) {
    final subject = subjectColorFor(slot.subjectLabel);

    return Card(
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant
              .withValues(alpha: 0.6),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          child: Row(
            children: [
              _TimeGutter(start: slot.startTime, end: slot.endTime, dimmed: true),
              Opacity(opacity: 0.55, child: SubjectBadge(subject: subject)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${slot.subjectLabel}${slot.groupLabel != null ? ' — Groupe ${slot.groupLabel}' : ''}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Appuyer pour créer',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              if (onGenerate != null)
                IconButton(
                  tooltip: 'Générer avec l\'IA',
                  icon: const Icon(
                    Icons.auto_awesome,
                    color: AppColors.aiProposed,
                  ),
                  onPressed: onGenerate,
                ),
              Icon(
                Icons.add_circle_outline,
                color: Theme.of(context).colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

}

/// Colonne d'heures à gauche de chaque carte : début en gras, fin en dessous.
/// Auparavant l'horaire était noyé dans la ligne de sous-titre, ce qui rendait
/// la journée illisible d'un coup d'œil (tout arrivait « d'un bloc »).
class _TimeGutter extends StatelessWidget {
  const _TimeGutter({required this.start, this.end, this.dimmed = false});

  final String? start;
  final String? end;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (start == null) return const SizedBox(width: 44);
    return SizedBox(
      width: 44,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            start!.substring(0, 5),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: dimmed ? scheme.outline : scheme.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (end != null)
            Text(
              end!.substring(0, 5),
              style: TextStyle(
                fontSize: 11,
                color: scheme.outline,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
        ],
      ),
    );
  }
}

/// En-tête « Matin » / « Après-midi », avec le nombre de séances de la demi-journée.
class _DayPartHeader extends StatelessWidget {
  const _DayPartHeader({
    required this.label,
    required this.icon,
    required this.seanceCount,
  });

  final String label;
  final IconData icon;
  final int seanceCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 16, color: scheme.outline),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: scheme.outline,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: scheme.outlineVariant.withValues(alpha: 0.6))),
          const SizedBox(width: 8),
          Text(
            '$seanceCount séance${seanceCount > 1 ? 's' : ''}',
            style: TextStyle(fontSize: 11, color: scheme.outline),
          ),
        ],
      ),
    );
  }
}

/// Récréation / pause déjeuner : une ligne fine, pas une carte — elles
/// rythment la journée sans prendre la place des séances.
class _BreakRow extends StatelessWidget {
  const _BreakRow({required this.slot});

  final ScheduleSlot slot;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLunch = slot.subjectLabel.toLowerCase().contains('déjeuner');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(
              slot.startTime.substring(0, 5),
              style: TextStyle(
                fontSize: 11,
                color: scheme.outline,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Icon(
            isLunch ? Icons.restaurant_outlined : Icons.sports_soccer_outlined,
            size: 14,
            color: scheme.outline,
          ),
          const SizedBox(width: 6),
          Text(
            slot.subjectLabel,
            style: TextStyle(fontSize: 12, color: scheme.outline),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(
              color: scheme.outlineVariant.withValues(alpha: 0.5),
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.text,
    this.showClassroom = false,
  });

  final IconData icon;
  final String text;
  final bool showClassroom;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final classroom = Image.asset(
      'assets/branding/onboarding_premiere_classe.png',
      width: 160,
    );

    return EmptyState(
      icon: icon,
      title: text,
      illustration: showClassroom
          ? Opacity(
              opacity: 0.85,
              child: isDark
                  ? ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                        Color(0xFFAEB9CE),
                        BlendMode.srcIn,
                      ),
                      child: classroom,
                    )
                  : classroom,
            )
          : null,
    );
  }
}
