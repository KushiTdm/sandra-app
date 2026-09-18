import 'package:cahier_journal_ce1/core/theme/app_theme.dart';
import 'package:cahier_journal_ce1/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sans émulateur Android ni appareil connecté à cette machine, ce test est
/// le seul moyen de VOIR un écran plutôt que de raisonner dessus : il pousse
/// un golden file (PNG) sur disque via `--update-goldens`, ensuite consulté
/// avec l'outil de lecture d'images — exactement comme une capture d'écran
/// envoyée par Sandra, mais générée ici plutôt qu'attendue d'elle.
///
/// Reproduction fidèle et minimale de la structure d'`AppShell` : un
/// `Scaffold` extérieur en `extendBody: true` avec une barre de navigation
/// flottante, et un écran empilé à l'intérieur (comme `GenerationScreen`,
/// `GenerationValidationScreen`, ou toute feuille modale) avec un bouton
/// d'action tout en bas — exactement la configuration qui a cache plusieurs
/// boutons « Valider » à Sandra le 16 septembre 2026. Un golden sans marge
/// (le bug), un golden avec `AppSpacing.bottomNavClearance` (le correctif).
Widget _shellWith({required double innerBottomPadding}) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(
      extendBody: true,
      body: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Écran empilé (ex. validation)')),
          body: Padding(
            padding: EdgeInsets.only(bottom: innerBottomPadding),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: const [
                      ListTile(title: Text('Séance 1 — Grammaire')),
                      ListTile(title: Text('Séance 2 — Numération')),
                      ListTile(title: Text('Séance 3 — Lecture')),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const TextButton(onPressed: null, child: Text('Rejeter')),
                    const Spacer(),
                    FilledButton(
                      onPressed: () {},
                      child: const Text('VALIDER'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF14141C),
            borderRadius: BorderRadius.circular(28),
          ),
          alignment: Alignment.center,
          child: const Text(
            'BARRE DE NAVIGATION FLOTTANTE (AppShell)',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ),
      ),
    ),
  );
}

void main() {
  // Taille d'un téléphone Android courant en pixels logiques — le défaut de
  // test (800x600) est trop petit pour juger d'un recouvrement en bas
  // d'écran.
  const phoneSize = Size(400, 860);

  Future<void> setPhoneSize(WidgetTester tester) async {
    tester.view.physicalSize = phoneSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('AVANT correctif : le bouton Valider est caché par la barre flottante',
      (tester) async {
    await setPhoneSize(tester);
    await tester.pumpWidget(_shellWith(innerBottomPadding: 0));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/bottom_nav_overlap_avant.png'),
    );
  });

  testWidgets('APRÈS correctif (AppSpacing.bottomNavClearance) : le bouton reste visible',
      (tester) async {
    await setPhoneSize(tester);
    await tester.pumpWidget(_shellWith(innerBottomPadding: AppSpacing.bottomNavClearance));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/bottom_nav_overlap_apres.png'),
    );
  });
}
