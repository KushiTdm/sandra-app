import 'package:flutter/material.dart';

import '../../core/supabase/supabase_bootstrap.dart';
import '../edt/edt_screen.dart';
import 'ai_preferences_screen.dart';
import 'commentaires_screen.dart';
import 'import_journal_screen.dart';

class ReglagesScreen extends StatelessWidget {
  const ReglagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final email = supabase.auth.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Plus')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Connecté en tant que'),
            subtitle: Text(email),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.calendar_month_outlined),
            title: Text('Périodes et calendrier'),
            subtitle: Text('À venir — réglage des dates de vacances (Lot 3)'),
            enabled: false,
          ),
          ListTile(
            leading: const Icon(Icons.schedule_outlined),
            title: const Text('Emploi du temps'),
            subtitle: const Text('Corriger un créneau ou créer une nouvelle version'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EdtScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.psychology_outlined),
            title: const Text('Préférences de génération IA'),
            subtitle: const Text('Ce que l\'IA a retenu de vos réponses au wizard'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AiPreferencesScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: const Text('Importer une page du cahier journal'),
            subtitle: const Text('Depuis une photo, ou un JSON obtenu ailleurs'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ImportJournalScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.chat_bubble_outline),
            title: const Text('Commentaires sur l\'application'),
            subtitle: const Text('Remarques, idées, bugs à signaler'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CommentairesScreen()),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Se déconnecter'),
            onTap: () => supabase.auth.signOut(),
          ),
        ],
      ),
    );
  }
}
