import 'package:supabase_flutter/supabase_flutter.dart';

import '../env/env.dart';

Future<void> initSupabase() async {
  Env.assertConfigured();
  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabasePublishableKey,
  );
}

/// Accès direct au client Supabase courant (JWT de l'utilisateur connecté).
/// Toutes les requêtes passent donc par la RLS avec ses propres droits (R4).
SupabaseClient get supabase => Supabase.instance.client;
