import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'day_journal_view.dart';
import 'exercices/exercices_generation_sheet.dart';
import 'generation/generation_providers.dart';
import 'generation/generation_screen.dart';
import 'journal_providers.dart';
import 'matiere_journal_view.dart';
import 'pdf/journal_pdf_export.dart';
import 'semaine_journal_view.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  DateTime _selectedDate = _today();
  DateTime _weekStart = _mondayOf(_today());

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime _mondayOf(DateTime date) => date.subtract(Duration(days: date.weekday - 1));

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openGeneration(String classId) async {
    final resumable = await ref.read(resumableGenerationProvider(classId).future);
    String? resumeId;
    if (resumable != null) {
      if (!mounted) return;
      final choice = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Génération en cours'),
          content: Text(
            'Une préparation ${resumable.scope == 'semaine' ? 'de semaine' : 'de jour'} n\'est pas terminée '
            '(${resumable.processedDates.length} jour(s) déjà fait(s)). Reprendre, ou en démarrer une nouvelle ?',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop('nouvelle'), child: const Text('Nouvelle')),
            FilledButton(onPressed: () => Navigator.of(context).pop('reprendre'), child: const Text('Reprendre')),
          ],
        ),
      );
      if (choice == 'reprendre') resumeId = resumable.id;
    }
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GenerationScreen(classId: classId, resumeRequestId: resumeId)),
    );
  }

  /// Choix demandé par Sandra (18 septembre 2026) : exporter juste le jour
  /// affiché, ou toute la semaine — jusqu'ici un seul bouton exportait
  /// toujours la semaine entière.
  Future<void> _exportPdf(String classId) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text('Exporter en PDF', style: Theme.of(context).textTheme.titleMedium),
            ),
            ListTile(
              leading: const Icon(Icons.today_outlined),
              title: Text('Ce jour — ${DateFormat('EEEE d MMMM', 'fr_FR').format(_selectedDate)}'),
              onTap: () => Navigator.of(context).pop('jour'),
            ),
            ListTile(
              leading: const Icon(Icons.date_range_outlined),
              title: Text(
                'Toute la semaine — ${DateFormat('d MMM', 'fr_FR').format(_weekStart)} au '
                '${DateFormat('d MMM', 'fr_FR').format(_weekStart.add(const Duration(days: 4)))}',
              ),
              onTap: () => Navigator.of(context).pop('semaine'),
            ),
          ],
        ),
      ),
    );
    if (choice == null || !mounted) return;
    if (choice == 'jour') {
      await exportJournalToPdf(context, ref, classId: classId, dates: [_selectedDate], filenameSuffix: 'jour');
    } else {
      final weekDates = List.generate(5, (i) => _weekStart.add(Duration(days: i)));
      await exportJournalToPdf(context, ref, classId: classId, dates: weekDates, filenameSuffix: 'semaine');
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
        _weekStart = _mondayOf(_selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final classId = ref.watch(journalClassIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Jour'), Tab(text: 'Semaine'), Tab(text: 'Par matière')],
        ),
        actions: [
          classId.maybeWhen(
            data: (id) => IconButton(
              tooltip: 'Générer avec l\'IA (jour ou semaine)',
              icon: const Icon(Icons.auto_awesome_outlined),
              onPressed: () => _openGeneration(id),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          IconButton(
            tooltip: 'Générer des exercices (choisir la matière)',
            icon: const Icon(Icons.assignment_outlined),
            onPressed: () => showExercicesForDomainSheet(context),
          ),
          classId.maybeWhen(
            data: (id) => IconButton(
              tooltip: 'Exporter en PDF',
              icon: const Icon(Icons.picture_as_pdf_outlined),
              onPressed: () => _exportPdf(id),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          IconButton(
            tooltip: 'Choisir une date',
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: _pickDate,
          ),
        ],
      ),
      body: classId.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (id) => TabBarView(
          controller: _tabController,
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(_selectedDate),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                const Divider(height: 1),
                Expanded(child: DayJournalView(classId: id, date: _selectedDate)),
              ],
            ),
            SemaineJournalView(
              classId: id,
              weekStart: _weekStart,
              onWeekChanged: (start) => setState(() => _weekStart = start),
              onDaySelected: (date) => setState(() {
                _selectedDate = date;
                _tabController.index = 0;
              }),
            ),
            MatiereJournalView(classId: id),
          ],
        ),
      ),
    );
  }
}
