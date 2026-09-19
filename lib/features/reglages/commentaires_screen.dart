import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/result/result.dart';
import '../../core/supabase/supabase_bootstrap.dart';
import '../../data/repositories/feedback_repository.dart';
import '../journal/journal_providers.dart';

final _feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) => FeedbackRepository(supabase));

const _categoryLabels = {'bug': 'Bug', 'idee': 'Idée', 'autre': 'Autre'};

/// Section "Commentaires" (§11, Plus) : Sandra note ses remarques sur
/// l'application — bugs, idées d'amélioration, nouvelles fonctionnalités —
/// pour elle-même, sans autre traitement dans l'app.
class CommentairesScreen extends ConsumerStatefulWidget {
  const CommentairesScreen({super.key});

  @override
  ConsumerState<CommentairesScreen> createState() => _CommentairesScreenState();
}

class _CommentairesScreenState extends ConsumerState<CommentairesScreen> {
  List<AppFeedback>? _items;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final classId = await ref.read(journalClassIdProvider.future);
      final items = await ref.read(_feedbackRepositoryProvider).list(classId);
      if (mounted) setState(() => _items = items);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  Future<void> _add() async {
    var category = 'idee';
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nouveau commentaire'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'bug', label: Text('Bug')),
                  ButtonSegment(value: 'idee', label: Text('Idée')),
                  ButtonSegment(value: 'autre', label: Text('Autre')),
                ],
                selected: {category},
                onSelectionChanged: (s) => setDialogState(() => category = s.first),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: 'Votre remarque…', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
            FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Ajouter')),
          ],
        ),
      ),
    );
    if (result != true || controller.text.trim().isEmpty) return;

    try {
      final classId = await ref.read(journalClassIdProvider.future);
      await ref.read(_feedbackRepositoryProvider).add(classId: classId, category: category, body: controller.text.trim());
      await _load();
    } on AppException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Échec : ${e.message}')));
    }
  }

  Future<void> _delete(AppFeedback item) async {
    setState(() => _items = _items!.where((i) => i.id != item.id).toList());
    try {
      await ref.read(_feedbackRepositoryProvider).delete(item.id);
    } on AppException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Échec : ${e.message}')));
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Commentaires')),
      floatingActionButton: FloatingActionButton(onPressed: _add, child: const Icon(Icons.add)),
      body: _error != null
          ? Center(child: Text('Erreur : $_error'))
          : _items == null
              ? const Center(child: CircularProgressIndicator())
              : _items!.isEmpty
                  ? const Center(child: Text('Aucun commentaire pour l\'instant.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _items!.length,
                      itemBuilder: (context, i) {
                        final item = _items![i];
                        return Dismissible(
                          key: ValueKey(item.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            color: Theme.of(context).colorScheme.errorContainer,
                            child: const Icon(Icons.delete_outline),
                          ),
                          onDismissed: (_) => _delete(item),
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 6),
                            child: ListTile(
                              title: Text(item.body),
                              subtitle: Text(
                                '${_categoryLabels[item.category] ?? item.category} · '
                                '${DateFormat('d MMMM yyyy à HH:mm', 'fr_FR').format(item.createdAt)}',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
