import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../core/result/result.dart';
import '../../core/theme/app_tokens.dart';
import '../journal/journal_providers.dart';
import 'vie_de_classe_providers.dart';

const _typeLabels = {
  'positif': 'Positif',
  'difficulte': 'Difficulté',
  'comportement': 'Comportement',
  'sante': 'Santé',
  'materiel': 'Matériel',
  'autre': 'Autre',
};

/// Signalement rapide (FAB, écran 4 du design) : commenter un ou plusieurs
/// élèves en quelques gestes, dictée vocale possible. Sert aussi de base à
/// la fiche élève (§8, Lot 8) et, agrégé, au contexte de génération IA.
Future<void> showSignalementSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => const _SignalementSheet(),
  );
}

class _SignalementSheet extends ConsumerStatefulWidget {
  const _SignalementSheet();

  @override
  ConsumerState<_SignalementSheet> createState() => _SignalementSheetState();
}

class _SignalementSheetState extends ConsumerState<_SignalementSheet> {
  final Set<String> _selectedStudentIds = {};
  String _type = 'comportement';
  int _severity = 1;
  final _bodyController = TextEditingController();
  bool _saving = false;
  String? _error;

  late final stt.SpeechToText _speech;
  bool _speechAvailable = false;
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _speech.initialize().then((available) {
      if (mounted) setState(() => _speechAvailable = available);
    }).catchError((_) {
      // Reconnaissance vocale indisponible sur cet appareil (ex. poste
      // Windows sans service de dictée configuré) : on reste sans dictée.
      if (mounted) setState(() => _speechAvailable = false);
    });
  }

  @override
  void dispose() {
    _bodyController.dispose();
    if (_listening) _speech.stop();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      return;
    }
    setState(() => _listening = true);
    // ignore: deprecated_member_use
    await _speech.listen(
      // ignore: deprecated_member_use
      localeId: 'fr_FR',
      onResult: (result) {
        setState(() {
          _bodyController.text = result.recognizedWords;
          _bodyController.selection = TextSelection.collapsed(offset: _bodyController.text.length);
        });
      },
    );
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final classId = await ref.read(journalClassIdProvider.future);
      final synced = await ref.read(vieDeClasseRepositoryProvider).createObservation(
            classId: classId,
            date: DateTime.now(),
            type: _type,
            severity: _severity,
            body: _bodyController.text.trim().isEmpty ? null : _bodyController.text.trim(),
            studentIds: _selectedStudentIds.toList(),
          );
      if (!mounted) return;
      for (final id in _selectedStudentIds) {
        ref.invalidate(observationsForStudentProvider(id));
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(synced ? 'Signalement enregistré.' : 'Signalement enregistré (en attente de réseau).')),
      );
    } on AppException catch (e) {
      setState(() {
        _error = e.message;
        _saving = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Échec : $e';
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final students = ref.watch(studentsProvider);

    return Padding(
      // Marge basse = clavier (variable) + barre de nav flottante (fixe) :
      // cette feuille est une fenêtre modale ouverte depuis un onglet, donc
      // affichée derrière la barre de navigation flottante de l'app (voir
      // AppSpacing.bottomNavClearance) — sans ça son bouton « Enregistrer »
      // atterrit dans la zone qu'elle recouvre.
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.bottomNavClearance,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Signalement rapide', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Text('Élève(s) concerné(s)', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              students.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Erreur : $e'),
                data: (list) => Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: list.map((s) {
                    final selected = _selectedStudentIds.contains(s.id);
                    return FilterChip(
                      label: Text(s.displayName),
                      selected: selected,
                      onSelected: (v) => setState(() {
                        if (v) {
                          _selectedStudentIds.add(s.id);
                        } else {
                          _selectedStudentIds.remove(s.id);
                        }
                      }),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              Text('Type', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                children: _typeLabels.entries
                    .map((e) => ChoiceChip(
                          label: Text(e.value),
                          selected: _type == e.key,
                          onSelected: (_) => setState(() => _type = e.key),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              Text('Importance', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 1, label: Text('Mineure')),
                  ButtonSegment(value: 2, label: Text('Modérée')),
                  ButtonSegment(value: 3, label: Text('Importante')),
                ],
                selected: {_severity},
                onSelectionChanged: (s) => setState(() => _severity = s.first),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _bodyController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description',
                  suffixIcon: _speechAvailable
                      ? IconButton(
                          icon: Icon(_listening ? Icons.mic : Icons.mic_none_outlined),
                          color: _listening ? Theme.of(context).colorScheme.error : null,
                          tooltip: 'Dicter',
                          onPressed: _toggleListening,
                        )
                      : null,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Enregistrer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
