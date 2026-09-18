import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../models/schedule_slot.dart';

const _dayNames = {1: 'Lundi', 2: 'Mardi', 3: 'Mercredi', 4: 'Jeudi', 5: 'Vendredi'};

/// Export PDF de l'emploi du temps en vigueur (Sandra, 18 septembre 2026).
///
/// Grille horaire × jour, comme un emploi du temps classique — pas 5
/// colonnes de jour empilées côte à côte : sur une semaine réelle (jusqu'à
/// 15 créneaux certains jours, groupes A/B compris), 5 colonnes indépendantes
/// dans un simple `Row`/`Expanded` dépassaient la hauteur d'une page fixe et
/// ne s'affichaient tout simplement pas (page blanche, signalé par Sandra) :
/// un `Row` ne sait pas se répartir sur plusieurs pages. Un `pw.Table` dans
/// un `pw.MultiPage`, si : les lignes qui ne tiennent pas continuent sur une
/// page suivante, comme le fait déjà l'export du cahier journal.
///
/// L'axe des lignes est l'union des horaires de **début** rencontrés dans la
/// semaine (les horaires de fin varient plus souvent — ex. jeudi, la séance
/// d'EPS des spécialistes dure 55 min au lieu des 25 min habituels — sans
/// désaligner la ligne suivante, qui redémarre pile au bon horaire commun).
Future<void> exportEdtToPdf(
  BuildContext context, {
  required List<ScheduleSlot> slots,
  required String versionLabel,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  messenger.showSnackBar(const SnackBar(content: Text('Préparation du PDF…'), duration: Duration(seconds: 30)));

  try {
    final fontRegular = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();
    final doc = pw.Document(theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold));

    final startTimes = slots.map((s) => s.startTime).toSet().toList()..sort();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'page ${context.pageNumber}/${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
        ),
        build: (context) => [
          pw.Text('Emploi du temps — CE1', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 2),
          pw.Text(versionLabel, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          pw.SizedBox(height: 12),
          _grid(startTimes, slots),
        ],
      ),
    );

    messenger.hideCurrentSnackBar();
    await Printing.sharePdf(bytes: await doc.save(), filename: 'emploi_du_temps.pdf');
  } catch (e) {
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text('Échec de l\'export PDF : $e')));
  }
}

pw.Widget _grid(List<String> startTimes, List<ScheduleSlot> slots) {
  return pw.Table(
    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.4),
    columnWidths: {
      0: const pw.FixedColumnWidth(34),
      for (var day = 1; day <= 5; day++) day: const pw.FlexColumnWidth(1),
    },
    children: [
      pw.TableRow(
        repeat: true, // rejouée en haut de chaque page si la grille continue.
        decoration: const pw.BoxDecoration(color: PdfColors.grey300),
        children: [
          _headerCell(''),
          for (var day = 1; day <= 5; day++) _headerCell(_dayNames[day]!),
        ],
      ),
      for (final time in startTimes)
        pw.TableRow(
          children: [
            _timeCell(time),
            for (var day = 1; day <= 5; day++) _cell(slots, day, time),
          ],
        ),
    ],
  );
}

pw.Widget _headerCell(String label) => pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        label,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
      ),
    );

pw.Widget _timeCell(String time) => pw.Padding(
      padding: const pw.EdgeInsets.all(3),
      child: pw.Text(
        time.substring(0, 5),
        style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
      ),
    );

/// Le créneau (ou les deux, groupes A/B) qui démarrent à cet horaire ce
/// jour-là — vide sinon (récréation ou aucun cours à cette heure précise).
pw.Widget _cell(List<ScheduleSlot> slots, int day, String time) {
  final matches = slots.where((s) => s.dayOfWeek == day && s.startTime == time).toList();
  if (matches.isEmpty) return pw.SizedBox();
  return pw.Padding(
    padding: const pw.EdgeInsets.all(2),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: matches.map(_slotChip).toList(),
    ),
  );
}

pw.Widget _slotChip(ScheduleSlot slot) {
  if (slot.isBreak) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Text(
        slot.subjectLabel,
        style: pw.TextStyle(fontSize: 6.5, color: PdfColors.grey500, fontStyle: pw.FontStyle.italic),
      ),
    );
  }

  final isSpecialist = slot.taughtBy == 'specialist';
  return pw.Container(
    width: double.infinity,
    margin: const pw.EdgeInsets.only(bottom: 2),
    padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 2),
    decoration: pw.BoxDecoration(
      color: isSpecialist ? PdfColors.grey200 : PdfColors.blue50,
      borderRadius: pw.BorderRadius.circular(2),
    ),
    child: pw.Text(
      '${slot.subjectLabel}${slot.groupLabel != null ? ' (${slot.groupLabel})' : ''}',
      style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
    ),
  );
}
