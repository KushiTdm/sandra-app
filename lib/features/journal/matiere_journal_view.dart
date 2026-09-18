import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../data/repositories/edt_repository.dart';
import '../../models/journal_entry.dart';
import '../../core/supabase/supabase_bootstrap.dart';
import 'entry_editor_sheet.dart';
import 'journal_providers.dart';

final _domainsProvider = FutureProvider.autoDispose<List<CurriculumDomain>>((ref) async {
  final classId = await ref.watch(journalClassIdProvider.future);
  return EdtRepository(supabase).knownDomains(classId);
});

/// Vue Par matière (§8.3) : fil chronologique d'un domaine sur la classe,
/// pour voir la progression et le tissage d'une notion à l'autre.
class MatiereJournalView extends ConsumerStatefulWidget {
  const MatiereJournalView({super.key, required this.classId});

  final String classId;

  @override
  ConsumerState<MatiereJournalView> createState() => _MatiereJournalViewState();
}

class _MatiereJournalViewState extends ConsumerState<MatiereJournalView> {
  String? _selectedDomain;

  @override
  Widget build(BuildContext context) {
    final domains = ref.watch(_domainsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: domains.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Erreur : $e'),
            data: (list) {
              _selectedDomain ??= list.isNotEmpty ? list.first.code : null;
              if (list.isEmpty) return const Text('Aucun domaine rattaché à l\'EDT.');
              return DropdownButtonFormField<String>(
                initialValue: _selectedDomain,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Matière et domaine'),
                // Deux lignes dans la liste déroulante (matière + intitulé),
                // une seule ligne tronquée une fois sélectionné : les
                // intitulés du référentiel sont longs, et le code brut
                // (« FR.CNJ ») ne veut rien dire pour Sandra.
                selectedItemBuilder: (context) => list
                    .map((d) => Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            d.fullLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                items: list
                    .map((d) => DropdownMenuItem(
                          value: d.code,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                d.subjectLabel,
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                              Text(
                                d.label,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedDomain = v),
              );
            },
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _selectedDomain == null
              ? const SizedBox.shrink()
              : _DomainFeed(classId: widget.classId, domainCode: _selectedDomain!),
        ),
      ],
    );
  }
}

class _DomainFeed extends ConsumerWidget {
  const _DomainFeed({required this.classId, required this.domainCode});

  final String classId;
  final String domainCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(journalRepositoryProvider);

    return FutureBuilder<List<({JournalEntry entry, DateTime date})>>(
      future: repo.entriesForDomain(classId, domainCode),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur : ${snapshot.error}'));
        }
        final items = snapshot.data ?? const [];
        if (items.isEmpty) {
          return const Center(child: Text('Aucune séance saisie pour ce domaine.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 6),
          itemBuilder: (context, index) {
            final item = items[items.length - 1 - index]; // plus récent d'abord
            final entry = item.entry;
            return Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                onTap: () => showEntryEditorSheet(
                  context,
                  classId: classId,
                  date: item.date,
                  subjectLabel: entry.subjectLabel,
                  domainCode: entry.domainCode,
                  groupLabel: entry.groupLabel,
                  startTime: entry.startTime,
                  endTime: entry.endTime,
                  initial: entry,
                ),
                leading: CircleAvatar(
                  backgroundColor: entry.status == 'faite'
                      ? AppColors.masteryAcquis.withValues(alpha: 0.2)
                      : AppColors.masteryNonVu.withValues(alpha: 0.2),
                  child: Icon(
                    entry.status == 'faite' ? Icons.check : Icons.schedule,
                    size: 18,
                    color: entry.status == 'faite' ? AppColors.masteryAcquis : AppColors.masteryNonVu,
                  ),
                ),
                title: Text(entry.title?.isNotEmpty == true ? entry.title! : entry.subjectLabel),
                subtitle: Text(DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(item.date)),
              ),
            );
          },
        );
      },
    );
  }
}
