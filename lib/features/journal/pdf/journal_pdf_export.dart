import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/supabase/supabase_bootstrap.dart';
import '../../../models/journal_entry.dart';
import '../../../models/schedule_slot.dart';
import '../journal_providers.dart';

/// Export PDF du cahier journal (§8.4) : A4 **portrait**, un jour par page,
/// une séance par bloc empilé (plutôt qu'un tableau à 5 colonnes en paysage,
/// illisible sur un téléphone sans défilement horizontal — retour de Sandra,
/// 18 septembre 2026). Police Noto Sans (téléchargée à la demande, mise en
/// cache) : les prénoms vietnamiens avec diacritiques doivent s'afficher
/// correctement, ce que les polices de base d'un PDF (Helvetica…) ne
/// garantissent pas.
///
/// [dates] porte la sélection : un seul jour, ou toute une semaine — c'est
/// l'appelant qui choisit (voir `journal_screen.dart`, choix « Ce jour » /
/// « Toute la semaine »).
Future<void> exportJournalToPdf(
  BuildContext context,
  WidgetRef ref, {
  required String classId,
  required List<DateTime> dates,
  required String filenameSuffix,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  messenger.showSnackBar(const SnackBar(content: Text('Préparation du PDF…'), duration: Duration(seconds: 30)));

  try {
    final fontRegular = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();
    final fontItalic = await PdfGoogleFonts.notoSansItalic();
    final periods = await _loadPeriodLabels(classId);

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold, italic: fontItalic),
    );

    final dayBlocks = <({DateTime date, List<ScheduleSlot> teaching, List<JournalEntry> entries})>[];
    for (final date in dates) {
      final slots = await ref.read(scheduleForDateProvider(date).future);
      final journal = await ref.read(dayJournalProvider(date).future);
      // Tous les cours de la journée, y compris ceux assurés par un
      // intervenant (Anglais, Vietnamien, EPS/Arts) : le cahier journal rend
      // compte de la journée entière de la classe, pas seulement des séances
      // rédigées par l'enseignante (Sandra, 21 septembre 2026).
      final teaching = slots.where((s) => !s.isBreak).toList();
      if (teaching.isNotEmpty || journal.entries.isNotEmpty) {
        dayBlocks.add((date: date, teaching: teaching, entries: journal.entries));
      }
    }

    if (dayBlocks.isEmpty) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(const SnackBar(content: Text('Rien à exporter pour cette sélection.')));
      return;
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              periods[dates.first] ?? '',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
            pw.Text(
              'page ${context.pageNumber}/${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ],
        ),
        build: (context) => [
          for (var i = 0; i < dayBlocks.length; i++) ...[
            if (i > 0) pw.NewPage(),
            pw.Text(
              'Cahier Journal — CE1 — '
              '${_capitalize(DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(dayBlocks[i].date))}',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 12),
            ..._dayBlocks(dayBlocks[i].teaching, dayBlocks[i].entries),
          ],
        ],
      ),
    );

    messenger.hideCurrentSnackBar();
    final label = 'cahier_journal_${DateFormat('yyyy-MM-dd').format(dates.first)}_$filenameSuffix.pdf';
    await Printing.sharePdf(bytes: await doc.save(), filename: label);
  } catch (e) {
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text('Échec de l\'export PDF : $e')));
  }
}

bool _overlaps(String aStart, String aEnd, String bStart, String bEnd) =>
    aStart.compareTo(bEnd) < 0 && bStart.compareTo(aEnd) < 0;

/// Même règle que l'écran (day_journal_view.dart) : toute séance saisie est
/// toujours imprimée, même si son horaire ne correspond à aucun créneau EDT
/// nominal (le cahier journal réel de Sandra subdivise parfois un créneau, ou
/// s'en écarte). Un créneau n'apparaît comme case vide que s'il ne chevauche
/// vraiment aucune séance.
List<pw.Widget> _dayBlocks(List<ScheduleSlot> teaching, List<JournalEntry> entries) {
  final uncoveredSlots = teaching.where((s) => !entries.any((e) =>
      e.startTime != null && e.endTime != null && _overlaps(e.startTime!, e.endTime!, s.startTime, s.endTime)));

  final timeline = [
    for (final e in entries) (time: e.startTime ?? '99:99', block: _entryBlock(e)),
    for (final s in uncoveredSlots) (time: s.startTime, block: _emptySlotBlock(s)),
  ]..sort((a, b) => a.time.compareTo(b.time));

  return timeline.map((t) => t.block).toList();
}

/// « Domaine & Intitulé » ne répète l'intitulé que s'il apporte quelque chose
/// de plus que le domaine — pour une bonne partie des séances importées,
/// les deux champs sont identiques (« Français (Dictée flash) » des deux
/// côtés) et l'afficher deux fois se lisait comme un doublon (Sandra, 18
/// septembre 2026), pas comme deux informations différentes.
pw.Widget _entryBlock(JournalEntry entry) {
  final horaire = entry.startTime != null
      ? '${entry.startTime!.substring(0, 5)}${entry.endTime != null ? '–${entry.endTime!.substring(0, 5)}' : ''}'
      : '';
  final distinctTitle =
      (entry.title != null && entry.title!.isNotEmpty && entry.title != entry.subjectLabel) ? entry.title : null;
  final deroulementLines =
      entry.deroulementSteps.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').toList();

  return pw.Container(
    width: double.infinity,
    margin: const pw.EdgeInsets.only(bottom: 8),
    padding: const pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey400, width: 0.6),
      borderRadius: pw.BorderRadius.circular(4),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Text(horaire,
                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
            if (entry.groupLabel != null) ...[
              pw.SizedBox(width: 10),
              pw.Text('Groupe ${entry.groupLabel}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
            ],
          ],
        ),
        pw.SizedBox(height: 2),
        pw.Text(entry.subjectLabel, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        if (distinctTitle != null)
          pw.Text(distinctTitle, style: const pw.TextStyle(fontSize: 10.5, fontStyle: pw.FontStyle.italic)),
        if (entry.competenceBo?.isNotEmpty ?? false) ...[
          pw.SizedBox(height: 5),
          pw.Text('Compétence : ${entry.competenceBo}', style: const pw.TextStyle(fontSize: 9)),
        ],
        if (entry.objective?.isNotEmpty ?? false) ...[
          pw.SizedBox(height: 3),
          pw.Text('Objectif : ${entry.objective}', style: const pw.TextStyle(fontSize: 9)),
        ],
        if (deroulementLines.isNotEmpty) ...[
          pw.SizedBox(height: 5),
          pw.Text('Déroulement', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
          for (final l in deroulementLines) pw.Text(l, style: const pw.TextStyle(fontSize: 9)),
        ],
        if (entry.differenciation?.isNotEmpty ?? false) ...[
          pw.SizedBox(height: 3),
          pw.Text('Différenciation : ${entry.differenciation}', style: const pw.TextStyle(fontSize: 9)),
        ],
        if (entry.materiel.isNotEmpty) ...[
          pw.SizedBox(height: 3),
          pw.Text('Matériel : ${entry.materiel.join(', ')}', style: const pw.TextStyle(fontSize: 9)),
        ],
      ],
    ),
  );
}

pw.Widget _emptySlotBlock(ScheduleSlot slot) {
  return pw.Container(
    width: double.infinity,
    margin: const pw.EdgeInsets.only(bottom: 8),
    padding: const pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey300, width: 0.6),
      borderRadius: pw.BorderRadius.circular(4),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '${slot.startTime.substring(0, 5)}–${slot.endTime.substring(0, 5)}'
          '${slot.groupLabel != null ? '   ·   Groupe ${slot.groupLabel}' : ''}',
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 2),
        pw.Text(slot.subjectLabel,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
        pw.Text(
            slot.taughtBy == 'me' ? '(pas encore saisi)' : '(assuré par un intervenant)',
            style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic, color: PdfColors.grey500)),
      ],
    ),
  );
}

String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

Future<Map<DateTime, String>> _loadPeriodLabels(String classId) async {
  final row = await supabase.from('classes').select('period_calendar').eq('id', classId).single();
  final periods = (row['period_calendar'] as List?) ?? const [];
  final result = <DateTime, String>{};
  for (final p in periods) {
    final debut = DateTime.tryParse(p['debut'] as String? ?? '');
    final fin = DateTime.tryParse(p['fin'] as String? ?? '');
    if (debut == null || fin == null) continue;
    var d = debut;
    while (!d.isAfter(fin)) {
      result[d] = 'Période ${p['periode']}';
      d = d.add(const Duration(days: 1));
    }
  }
  return result;
}
