import 'package:cahier_journal_ce1/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Garde-fou contre le retour de `minimumSize: Size.fromHeight(x)` dans le
/// thème des boutons. Cette écriture vaut `Size(double.infinity, x)` : dans
/// une Column elle donne le bouton pleine largeur recherché, mais dans une Row
/// — où les enfants non flexibles sont mesurés sans borne de largeur — le
/// bouton réclame une largeur infinie et ne laisse rien à ses voisins. En
/// debug c'est une assertion ; en release, c'est silencieux, et c'est ainsi
/// que le champ de saisie de l'assistant s'était retrouvé réduit à un trait de
/// 2 px sur le téléphone de Sandra (16 septembre 2026).
void main() {
  for (final entry in {'clair': AppTheme.light(), 'sombre': AppTheme.dark()}.entries) {
    final theme = entry.value;

    test('thème ${entry.key} : largeur minimale des boutons finie', () {
      final sizes = {
        'FilledButton': theme.filledButtonTheme.style?.minimumSize?.resolve({}),
        'OutlinedButton': theme.outlinedButtonTheme.style?.minimumSize?.resolve({}),
      };
      for (final MapEntry(key: name, value: size) in sizes.entries) {
        expect(size, isNotNull, reason: '$name devrait avoir une taille minimale');
        expect(
          size!.width.isFinite,
          isTrue,
          reason: '$name : largeur minimale infinie — utiliser '
              'SizedBox(width: double.infinity) au point d\'appel',
        );
      }
    });

    testWidgets('thème ${entry.key} : un bouton dans une Row laisse la place '
        'à un champ de saisie', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(child: TextField(key: Key('champ'))),
                const SizedBox(width: 8),
                FilledButton(onPressed: () {}, child: const Icon(Icons.send)),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      final width = tester.getSize(find.byKey(const Key('champ'))).width;
      expect(width, greaterThan(200), reason: 'champ écrasé par le bouton');
    });
  }
}
