import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/result/result.dart';
import '../../data/repositories/generation_repository.dart';
import '../journal/generation/generation_providers.dart';

/// Ce que l'IA a retenu des réponses de Sandra au wizard de génération
/// (§9.7) — pour qu'elle puisse voir ce qui est mémorisé, pas une boîte
/// noire, et l'oublier si une réponse ne vaut plus.
class AiPreferencesScreen extends ConsumerStatefulWidget {
  const AiPreferencesScreen({super.key});

  @override
  ConsumerState<AiPreferencesScreen> createState() => _AiPreferencesScreenState();
}

class _AiPreferencesScreenState extends ConsumerState<AiPreferencesScreen> {
  List<TeacherPreference>? _preferences;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await ref.read(generationRepositoryProvider).listPreferences();
      if (!mounted) return;
      setState(() {
        _preferences = prefs;
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  Future<void> _forget(TeacherPreference pref) async {
    try {
      await ref.read(generationRepositoryProvider).deletePreference(pref.key);
      if (!mounted) return;
      setState(() => _preferences!.removeWhere((p) => p.key == pref.key));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('« ${pref.label} » oubliée.')),
      );
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Échec : ${e.message}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Préférences de génération IA')),
      body: Builder(builder: (context) {
        if (_error != null) return Center(child: Text('Erreur : $_error'));
        if (_preferences == null) return const Center(child: CircularProgressIndicator());
        if (_preferences!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'Rien de mémorisé pour l\'instant. Pendant une génération de cahier journal, '
                'certaines réponses au wizard de questions pourront être retenues ici pour ne plus '
                'être redemandées.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: _preferences!.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final pref = _preferences![i];
            return ListTile(
              title: Text(pref.label),
              subtitle: Text(
                '${pref.value}\nMis à jour le ${DateFormat('dd/MM/yyyy').format(pref.updatedAt)}',
              ),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Oublier cette préférence',
                onPressed: () => _forget(pref),
              ),
            );
          },
        );
      }),
    );
  }
}
