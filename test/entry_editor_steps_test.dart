import 'package:cahier_journal_ce1/data/repositories/journal_repository.dart';
import 'package:cahier_journal_ce1/features/journal/entry_editor_sheet.dart';
import 'package:cahier_journal_ce1/features/journal/journal_providers.dart';
import 'package:cahier_journal_ce1/models/journal_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Les étapes du déroulement doivent pouvoir être modifiées sur place et
/// réordonnées (Sandra, 25 septembre 2026). Rejoué sur Android ET Windows :
/// sous Windows, une liste réordonnable imbriquée dans la feuille défilante
/// réclame le même ScrollController principal et Flutter lève une assertion —
/// invisible sur téléphone.
class _FakeJournalRepository implements JournalRepository {
  List<String>? savedSteps;

  @override
  Future<JournalEntry> updateEntry(
    String entryId, {
    required String subjectLabel,
    String? domainCode,
    String? groupLabel,
    String? title,
    String? competenceBo,
    String? objective,
    List<String> steps = const [],
    String? differenciation,
    List<String> materiel = const [],
    required String status,
  }) async {
    savedSteps = steps;
    return JournalEntry(id: entryId, dayId: 'jour', subjectLabel: subjectLabel, status: status, origin: 'ia');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _entry = JournalEntry(
  id: 'e1',
  dayId: 'jour',
  subjectLabel: 'Géométrie',
  status: 'prevue',
  origin: 'ia',
  deroulementSteps: ['Étape A', 'Étape B', 'Étape C'],
);

Future<_FakeJournalRepository> _openEditor(WidgetTester tester, TargetPlatform platform) async {
  tester.view.physicalSize = const Size(800, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final repo = _FakeJournalRepository();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [journalRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        theme: ThemeData(platform: platform),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showEntryEditorSheet(
                context,
                classId: 'c',
                date: DateTime(2026, 9, 25),
                subjectLabel: 'Géométrie',
                initial: _entry,
              ),
              child: const Text('ouvrir'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('ouvrir'));
  await tester.pumpAndSettle();
  return repo;
}

/// `tester.drag` envoie tout le geste d'un bloc, sans image intermédiaire :
/// insuffisant pour une liste réordonnable, qui calcule la position
/// d'insertion image par image. On rejoue donc le glissement en plusieurs temps.
Future<void> _dragHandle(WidgetTester tester, Finder handle, double dy) async {
  final gesture = await tester.startGesture(tester.getCenter(handle));
  await tester.pump(const Duration(milliseconds: 100));
  for (var i = 0; i < 4; i++) {
    await gesture.moveBy(Offset(0, dy / 4));
    await tester.pump(const Duration(milliseconds: 50));
  }
  await gesture.up();
  await tester.pumpAndSettle();
}

/// Textes des étapes dans l'ordre où ils sont affichés à l'écran.
List<String> _stepsOnScreen(WidgetTester tester) {
  final fields = tester
      .widgetList<TextField>(find.byType(TextField))
      .where((f) => f.controller!.text.startsWith('Étape'))
      .toList();
  final ordered = fields.toList()
    ..sort((a, b) {
      final ya = tester.getTopLeft(find.byWidget(a)).dy;
      final yb = tester.getTopLeft(find.byWidget(b)).dy;
      return ya.compareTo(yb);
    });
  return ordered.map((f) => f.controller!.text).toList();
}

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.windows]) {
    group('étapes du déroulement (${platform.name})', () {
      testWidgets('affiche les étapes existantes, chacune modifiable', (tester) async {
        await _openEditor(tester, platform);
        expect(_stepsOnScreen(tester), ['Étape A', 'Étape B', 'Étape C']);
        expect(tester.takeException(), isNull);
      });

      testWidgets('modifier une étape puis enregistrer conserve le texte modifié', (tester) async {
        final repo = await _openEditor(tester, platform);
        await tester.enterText(find.widgetWithText(TextField, 'Étape B'), 'Étape B corrigée');
        await tester.tap(find.text('Enregistrer'));
        await tester.pumpAndSettle();
        expect(repo.savedSteps, ['Étape A', 'Étape B corrigée', 'Étape C']);
      });

      testWidgets('glisser la poignée réordonne les étapes, et l\'ordre est enregistré', (tester) async {
        final repo = await _openEditor(tester, platform);

        // Descend la première étape sous la deuxième.
        await _dragHandle(tester, find.byIcon(Icons.drag_indicator).first, 70);
        await tester.pumpAndSettle();
        expect(_stepsOnScreen(tester), ['Étape B', 'Étape A', 'Étape C']);

        await tester.tap(find.text('Enregistrer'));
        await tester.pumpAndSettle();
        expect(repo.savedSteps, ['Étape B', 'Étape A', 'Étape C']);
      });

      testWidgets('remonter la dernière étape en tête', (tester) async {
        await _openEditor(tester, platform);
        await _dragHandle(tester, find.byIcon(Icons.drag_indicator).last, -140);
        await tester.pumpAndSettle();
        expect(_stepsOnScreen(tester), ['Étape C', 'Étape A', 'Étape B']);
      });

      testWidgets('un texte modifié suit son étape quand on la déplace', (tester) async {
        final repo = await _openEditor(tester, platform);
        await tester.enterText(find.widgetWithText(TextField, 'Étape A'), 'Étape A modifiée');
        await _dragHandle(tester, find.byIcon(Icons.drag_indicator).first, 70);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Enregistrer'));
        await tester.pumpAndSettle();
        expect(repo.savedSteps, ['Étape B', 'Étape A modifiée', 'Étape C']);
      });

      testWidgets('supprimer une étape retire seulement celle-là', (tester) async {
        final repo = await _openEditor(tester, platform);
        await tester.tap(find.byTooltip('Supprimer cette étape').at(1));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Enregistrer'));
        await tester.pumpAndSettle();
        expect(repo.savedSteps, ['Étape A', 'Étape C']);
      });

      testWidgets('une étape vidée n\'est pas enregistrée comme ligne blanche', (tester) async {
        final repo = await _openEditor(tester, platform);
        await tester.enterText(find.widgetWithText(TextField, 'Étape B'), '   ');
        await tester.tap(find.text('Enregistrer'));
        await tester.pumpAndSettle();
        expect(repo.savedSteps, ['Étape A', 'Étape C']);
      });
    });
  }
}
