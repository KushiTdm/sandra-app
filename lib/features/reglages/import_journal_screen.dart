import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/result/result.dart';
import '../../core/supabase/supabase_bootstrap.dart';
import '../../data/repositories/edt_repository.dart';
import '../../data/repositories/import_repository.dart';
import '../journal/ai_generation_sheet.dart';
import '../journal/journal_providers.dart';

/// Import d'une page du cahier journal (§8.2) : Sandra choisit une date, puis
/// soit prend/choisit une photo (OCR + structuration en app), soit colle un
/// JSON obtenu d'une IA externe avec le prompt fourni ici — les deux voies
/// produisent les mêmes propositions, validées séance par séance comme une
/// génération IA classique (`AiRepository`, réutilisé tel quel).
class ImportJournalScreen extends ConsumerStatefulWidget {
  const ImportJournalScreen({super.key});

  @override
  ConsumerState<ImportJournalScreen> createState() => _ImportJournalScreenState();
}

class _ImportJournalScreenState extends ConsumerState<ImportJournalScreen> {
  DateTime _date = DateTime.now();
  bool _busy = false;
  List<Map<String, dynamic>>? _propositions;
  final Set<String> _decided = {};
  String? _error;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickAndImportPhoto(ImageSource source) async {
    final classId = await ref.read(journalClassIdProvider.future);
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 90);
    if (picked == null) return;

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final storagePath = await ref.read(importRepositoryProvider).uploadPhoto(
            classId: classId,
            category: 'journal',
            file: File(picked.path),
          );
      final propositions = await ref.read(importRepositoryProvider).importJournalPhoto(
            date: _date,
            storagePath: storagePath,
          );
      if (!mounted) return;
      setState(() => _propositions = propositions);
    } catch (e) {
      if (mounted) setState(() => _error = _describeError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pasteJson() async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coller le JSON'),
        content: SizedBox(
          width: 480,
          child: TextField(
            controller: controller,
            maxLines: 12,
            decoration: const InputDecoration(
              hintText: '[ { "horaire": ..., "domaine": "MA.GEO", ... } ]',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.of(context).pop(controller.text), child: const Text('Importer')),
        ],
      ),
    );
    if (text == null || text.trim().isEmpty) return;

    List<Map<String, dynamic>> entries;
    try {
      final decoded = jsonDecode(text);
      if (decoded is! List) throw const FormatException('Le JSON doit être un tableau de séances.');
      entries = decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('JSON invalide : $e')));
      }
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final propositions = await ref.read(importRepositoryProvider).importJournalJson(date: _date, entries: entries);
      if (!mounted) return;
      setState(() => _propositions = propositions);
    } catch (e) {
      if (mounted) setState(() => _error = _describeError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _describeError(Object e) {
    if (e is ImportRateLimited) {
      final seconds = e.retryAt.difference(DateTime.now()).inSeconds.clamp(0, 999);
      return 'Quota de l\'IA atteint — réessayez dans ${seconds}s.';
    }
    if (e is ImportValidationFailed) return e.details.join(' ; ');
    if (e is AppException) return e.message;
    return e.toString();
  }

  Future<void> _showPrompt() async {
    final classId = await ref.read(journalClassIdProvider.future);
    final domains = await EdtRepository(supabase).knownDomains(classId);
    if (!mounted) return;
    final prompt = _externalPrompt(domains);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Prompt à envoyer à une IA externe', style: Theme.of(context).textTheme.titleMedium),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copier',
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: prompt));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Prompt copié.')));
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Envoyez votre photo du cahier journal à une IA capable de lire une '
                'image (ChatGPT, Claude...) avec ce texte, puis collez sa réponse ici avec "Coller un JSON".',
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: SelectableText(prompt),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _externalPrompt(List<CurriculumDomain> domains) {
    final codes = domains.map((d) => '${d.code} (${d.label})').join(', ');
    return '''Tu es assistante d'une enseignante de CE1. Voici une photo d'une page de son cahier journal papier. Transforme-la en un tableau JSON de séances, une par plage horaire distincte visible sur la page.

Codes de domaine autorisés (n'en utilise aucun autre) : $codes

Réponds UNIQUEMENT avec ce tableau JSON, un objet par séance :
[
  {
    "horaire": { "debut": "HH:MM", "fin": "HH:MM" },
    "domaine": "CODE_DU_REFERENTIEL",
    "intitule": "…",
    "competence_bo": "…",
    "objectif": "…",
    "deroulement": {
      "tissage": { "duree_min": 0, "texte": "…" },
      "consigne_decouverte": { "duree_min": 0, "texte": "…" },
      "recherche_application": { "duree_min": 0, "texte": "…" },
      "correction": { "duree_min": 0, "texte": "…" },
      "institutionnalisation": { "duree_min": 0, "texte": "…" }
    },
    "differenciation": { "flsco": "…", "aide": "…", "approfondissement": "…" },
    "materiel": ["…"],
    "notions": [{ "code": "…" }]
  }
]''';
  }

  Future<void> _accept(String id) async {
    try {
      await ref.read(aiRepositoryProvider).applyProposition(id);
      if (mounted) setState(() => _decided.add(id));
    } on AppException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Échec : ${e.message}')));
    }
  }

  Future<void> _reject(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rejeter cette séance ?'),
        content: const Text('Elle ne sera pas ajoutée au cahier journal.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Rejeter')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(aiRepositoryProvider).rejectProposition(id);
      if (mounted) setState(() => _decided.add(id));
    } on AppException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Échec : ${e.message}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Importer une page du cahier journal')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Date de la page'),
            subtitle: Text(DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(_date)),
            trailing: TextButton(onPressed: _busy ? null : _pickDate, child: const Text('Changer')),
          ),
          const Divider(),
          const SizedBox(height: 8),
          Text('Analyser une photo', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilledButton.icon(
                onPressed: _busy ? null : () => _pickAndImportPhoto(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Prendre une photo'),
              ),
              OutlinedButton.icon(
                onPressed: _busy ? null : () => _pickAndImportPhoto(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Depuis la galerie'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Ou coller un JSON obtenu ailleurs', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _busy ? null : _pasteJson,
                icon: const Icon(Icons.paste_outlined),
                label: const Text('Coller un JSON'),
              ),
              TextButton.icon(
                onPressed: _showPrompt,
                icon: const Icon(Icons.info_outline),
                label: const Text('Voir le prompt à copier'),
              ),
            ],
          ),
          if (_busy) const Padding(padding: EdgeInsets.only(top: 20), child: LinearProgressIndicator()),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          if (_propositions != null) ...[
            const SizedBox(height: 24),
            Text('${_propositions!.length} séance(s) détectée(s)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final p in _propositions!) _buildCard(p),
          ],
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> p) {
    final id = p['id'] as String;
    final payload = (p['payload'] as Map).cast<String, dynamic>();
    final horaire = (payload['horaire'] as Map?)?.cast<String, dynamic>();
    final decided = _decided.contains(id);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (horaire != null)
              Text(
                '${(horaire['debut'] as String).substring(0, 5)}–${(horaire['fin'] as String).substring(0, 5)}  '
                '${payload['domaine'] as String? ?? ''}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 4),
            Text(payload['intitule'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(payload['objectif'] as String? ?? '', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            if (decided)
              Text('Décidé', style: TextStyle(color: Theme.of(context).colorScheme.outline, fontStyle: FontStyle.italic))
            else
              Row(
                children: [
                  TextButton(onPressed: () => _reject(id), child: const Text('Rejeter')),
                  const Spacer(),
                  FilledButton(onPressed: () => _accept(id), child: const Text('Valider')),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
