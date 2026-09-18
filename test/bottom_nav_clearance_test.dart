import 'package:cahier_journal_ce1/core/theme/app_tokens.dart';
import 'package:flutter_test/flutter_test.dart';

/// Garde-fou contre le retour de la valeur magique en dur : tout écran
/// empilé dans le Navigator d'un onglet (Générer avec l'IA, Appel, Bilan du
/// soir, Nouvelle version d'EDT…) doit réserver `AppSpacing.bottomNavClearance`
/// sous son dernier bouton, sans quoi la barre de navigation flottante de
/// l'app (`AppShell`, `extendBody: true`) le recouvre — invisible bien que
/// fonctionnel. C'est ce qui rendait le bouton « Valider » du wizard de
/// génération injoignable (Sandra, 16 septembre 2026).
void main() {
  test('bottomNavClearance dépasse la hauteur réelle de la barre flottante', () {
    // Barre (voir app_theme.dart : height: 60) + sa marge basse (voir
    // app_shell.dart : Padding(..., 12)). La constante doit rester
    // confortablement au-dessus de cette somme, jamais en dessous.
    const navBarHeight = 60.0;
    const navBarBottomMargin = 12.0;
    expect(AppSpacing.bottomNavClearance, greaterThan(navBarHeight + navBarBottomMargin));
  });
}
