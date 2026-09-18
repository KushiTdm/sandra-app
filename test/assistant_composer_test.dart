import 'package:cahier_journal_ce1/core/theme/app_theme.dart';
import 'package:cahier_journal_ce1/features/assistant/assistant_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sandra signalait le 16 septembre 2026 : « L'assistant IA n'est pas
/// disponible, aucun input ne me permet d'entrer ma demande ni de bouton pour
/// valider. » Le champ était bien là, mais réduit à 2 px par le bouton d'envoi
/// (voir button_layout_test.dart). Ce test vérifie qu'on peut réellement
/// écrire une question et qu'un bouton d'envoi actif l'accompagne.
void main() {
  Future<void> pumpAssistant(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const AssistantScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('le champ de saisie est utilisable et le bouton d\'envoi présent',
      (tester) async {
    await pumpAssistant(tester);

    final field = find.byType(TextField);
    expect(field, findsOneWidget);
    expect(tester.getSize(field).width, greaterThan(200));

    final sendButton = find.widgetWithIcon(FilledButton, Icons.send);
    expect(sendButton, findsOneWidget);
    expect(tester.widget<FilledButton>(sendButton).onPressed, isNotNull);

    await tester.enterText(field, 'Qui était absent hier ?');
    expect(find.text('Qui était absent hier ?'), findsOneWidget);
  });

  testWidgets('les 4 questions suggérées sont visibles à l\'ouverture',
      (tester) async {
    await pumpAssistant(tester);
    expect(find.textContaining('Qui était absent'), findsOneWidget);
    expect(find.textContaining('grammaire'), findsOneWidget);
    expect(find.textContaining('emploi du temps'), findsWidgets);
    expect(find.textContaining('géométrie'), findsOneWidget);
  });
}
