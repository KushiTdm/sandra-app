/// Configuration publique de l'application (R3 : aucune clé secrète ici).
///
/// Valeurs injectées à la compilation via `--dart-define-from-file=env.json`
/// (voir `env.example.json` à la racine de `app/`). `SUPABASE_SECRET_KEY` et
/// `MISTRAL_API_KEY` ne doivent JAMAIS apparaître dans ce fichier ni dans l'app :
/// ce sont des secrets d'Edge Functions (règle R3, docs/PLAN_EXECUTION.md §2).
class Env {
  const Env._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;

  static void assertConfigured() {
    if (!isConfigured) {
      throw StateError(
        'Configuration manquante : lancez avec '
        '--dart-define-from-file=env.json (copiez env.example.json).',
      );
    }
  }
}
