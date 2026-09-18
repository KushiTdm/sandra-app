/// Grille et rayons partagés (docs/prompts/claude_design_prompt.md :
/// grille de 4 dp, coins 12 dp cartes / 20 dp bottom sheets).
abstract final class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;

  /// Marge basse à réserver sous tout contenu qui doit rester cliquable en
  /// bas d'un écran empilé dans le Navigator d'un onglet (`Navigator.of
  /// (context).push(...)`, sans `rootNavigator: true`). `AppShell` déclare
  /// `extendBody: true` pour que le contenu défile derrière sa barre de
  /// navigation flottante en verre dépoli — un effet voulu pour les listes,
  /// mais qui rend invisible tout bouton fixe placé tout en bas d'un écran
  /// empilé (la barre, peinte par-dessus, le recouvre). `SafeArea` ne
  /// protège pas de ça : cette marge n'est pas une contrainte système,
  /// seulement un widget Flutter voisin. Hauteur de la barre (60) + sa
  /// marge (12) + une respiration de confort tactile ~= 104 — valeur déjà en
  /// usage dans day_journal_view.dart, reprise ici pour le même motif signalé
  /// sur l'assistant de génération (bouton « Valider » du wizard rendu
  /// invisible, Sandra, 16 septembre 2026) : un seul nombre à tenir à jour si
  /// la barre change un jour.
  static const bottomNavClearance = 104.0;
}

abstract final class AppRadius {
  static const card = 16.0;
  static const chip = 100.0;
  static const sheet = 24.0;
  static const button = 14.0;
}
