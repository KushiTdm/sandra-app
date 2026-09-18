import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../data/repositories/exercises_repository.dart';

/// Export d'une fiche d'exercices (§8.4 « fiche d'exercices, 2 niveaux, A4
/// portrait ») : une page par niveau pour les élèves, puis une page de
/// correction pour l'enseignante. Même police Noto Sans que le cahier
/// journal — les diacritiques vietnamiens doivent s'imprimer correctement.
Future<void> exportExercicesToPdf(
  BuildContext context, {
  required ExerciseSheet sheet,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  messenger.showSnackBar(
    const SnackBar(content: Text('Préparation du PDF…'), duration: Duration(seconds: 30)),
  );

  try {
    final regular = await PdfGoogleFonts.notoSansRegular();
    final bold = await PdfGoogleFonts.notoSansBold();
    final italic = await PdfGoogleFonts.notoSansItalic();
    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: regular, bold: bold, italic: italic),
    );

    final dateLabel = DateFormat('d MMMM yyyy', 'fr_FR').format(sheet.date);

    for (final niveau in sheet.niveaux) {
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(36, 32, 36, 32),
          header: (context) => context.pageNumber == 1
              ? pw.SizedBox()
              : pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Text(
                    '${sheet.title} — ${niveau.label} (suite)',
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                  ),
                ),
          footer: (context) => _pageFooter(context),
          build: (context) => [
            _eleveHeader(sheet, niveau),
            ...niveau.exercices.map((ex) => _exerciceBlock(ex)),
          ],
        ),
      );
    }

    // Page de correction : jamais distribuée aux élèves, elle ferme le
    // document pour que l'enseignante puisse simplement ne pas l'imprimer.
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 32, 36, 32),
        footer: (context) => pw.Column(
          children: [
            pw.Text(
              'Correction — ne pas distribuer',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700, fontStyle: pw.FontStyle.italic),
            ),
            pw.SizedBox(height: 2),
            _pageFooter(context),
          ],
        ),
        build: (context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(sheet.subjectLabel.toUpperCase(),
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700, fontWeight: pw.FontWeight.bold)),
              pw.Text(dateLabel, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Text('Correction — ${sheet.title}',
              style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
          if (sheet.competenceBo.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text('Compétence : ${sheet.competenceBo}', style: const pw.TextStyle(fontSize: 9)),
          ],
          if (sheet.materiel.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text('Matériel : ${sheet.materiel.join(', ')}',
                style: const pw.TextStyle(fontSize: 9)),
          ],
          pw.SizedBox(height: 12),
          for (final niveau in sheet.niveaux) ...[
            pw.Text(niveau.label,
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            for (final ex in niveau.exercices)
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.RichText(
                  text: pw.TextSpan(
                    style: const pw.TextStyle(fontSize: 9.5),
                    children: [
                      pw.TextSpan(
                        text: '${ex.numero}. ',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.TextSpan(text: '${ex.consigne}  →  '),
                      pw.TextSpan(
                        text: ex.attendu,
                        style: const pw.TextStyle(color: PdfColors.green800),
                      ),
                    ],
                  ),
                ),
              ),
            pw.SizedBox(height: 8),
          ],
        ],
      ),
    );

    messenger.hideCurrentSnackBar();
    final slug = sheet.title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'exercices_${DateFormat('yyyy-MM-dd').format(sheet.date)}_$slug.pdf',
    );
  } catch (e) {
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text('Échec de l\'export PDF : $e')));
  }
}

/// Pied de page commun : « Classe de CE1A de madame Perosa » (texte demandé
/// tel quel par Sandra, 16 septembre 2026) à gauche, pagination à droite.
pw.Widget _pageFooter(pw.Context context) => pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Classe de CE1A de madame Perosa',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
        ),
        pw.Text(
          'page ${context.pageNumber}/${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
        ),
      ],
    );

pw.Widget _eleveHeader(ExerciseSheet sheet, NiveauFiche niveau) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      // Matière et titre bien visibles en haut du document (demande
      // explicite de Sandra) : la matière d'abord, en petit et en majuscules
      // comme un sur-titre, puis le titre en grand juste en dessous.
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            sheet.subjectLabel.toUpperCase(),
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(sheet.date),
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
        ],
      ),
      pw.SizedBox(height: 4),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Text(sheet.title,
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          ),
          // Ligne pour le prénom : la fiche est distribuée telle quelle.
          pw.Container(
            width: 160,
            padding: const pw.EdgeInsets.only(bottom: 2),
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(width: 0.8)),
            ),
            child: pw.Text('Prénom :', style: const pw.TextStyle(fontSize: 10)),
          ),
        ],
      ),
      pw.SizedBox(height: 6),
      if (sheet.consigneGenerale.isNotEmpty)
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey200,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(sheet.consigneGenerale, style: const pw.TextStyle(fontSize: 10.5)),
        ),
      if (niveau.aides.isNotEmpty) ...[
        pw.SizedBox(height: 8),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey500, width: 0.8),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Pour t\'aider',
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 3),
              for (final aide in niveau.aides)
                pw.Bullet(text: aide, style: const pw.TextStyle(fontSize: 10)),
            ],
          ),
        ),
      ],
      pw.SizedBox(height: 12),
    ],
  );
}

pw.Widget _exerciceBlock(Exercice ex) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 14),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('${ex.numero}. ${ex.consigne}',
            style: pw.TextStyle(fontSize: 11.5, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        for (final item in ex.items)
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 12, bottom: 5),
            child: pw.Text(item, style: const pw.TextStyle(fontSize: 11, lineSpacing: 3)),
          ),
        // Un exercice de production n'a pas de support : on imprime les lignes
        // sur lesquelles l'élève écrit, sinon la consigne flotte dans le vide.
        if (ex.isProduction)
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 12, top: 4),
            child: pw.Column(
              children: List.generate(
                3,
                (_) => pw.Container(
                  height: 22,
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey500, width: 0.6)),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
