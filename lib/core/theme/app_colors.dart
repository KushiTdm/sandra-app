import 'package:flutter/material.dart';

/// Palette validée dans docs/prompts/claude_design_prompt.md.
/// À remplacer par la planche « Design tokens » exportée par Sandra (Lot 0/2)
/// si elle diverge de ces valeurs — ce fichier reste alors le seul à modifier.
abstract final class AppColors {
  static const background = Color(0xFFFAF8F4);
  static const ink = Color(0xFF1F2430);
  static const primary = Color(0xFF2F4A6D);
  static const accent = Color(
    0xFFC8643B,
  ); // terracotta — actions principales, FAB

  static const aiProposed = Color(0xFF6B5CA5);

  static const masteryAcquis = Color(0xFF4F8A5B);
  static const masteryEnCours = Color(0xFF4A7FB5);
  static const masteryFragile = Color(0xFFD9962B);
  static const masteryNonAcquis = Color(0xFFB5483A);
  static const masteryNonVu = Color(0xFFB8BCC4);

  // Thème sombre — mêmes intentions de couleur, surfaces assombries.
  static const backgroundDark = Color(0xFF12161F);
  static const surfaceDark = Color(0xFF1B2130);
  static const inkDark = Color(0xFFEDEFF4);

  // Verre dépoli façon Apple (BackdropFilter) : superposition + liseré.
  // Le blanc/noir à faible opacité fonctionne sur n'importe quel fond
  // puisque c'est le flou de `GlassSurface` qui fait l'essentiel du travail.
  static const glassTintLight = Color(0xB3FFFFFF);
  static const glassTintDark = Color(0xB3232838);
  static const glassBorderLight = Color(0x66FFFFFF);
  static const glassBorderDark = Color(0x33FFFFFF);
}

/// Couleurs par matière (pastilles et bandeaux fins — jamais en aplat plein écran).
/// `iconAsset` pointe vers les pictogrammes découpés de
/// docs/prompts/asset_generation_prompts.md (section 2) ; `null` pour
/// `specialiste`, qui n'a pas de picto dédié (créneau non modifiable).
enum SubjectColor {
  francais(
    Color(0xFF3E6FA8),
    'assets/branding/subjects/icon_subject_francais.png',
  ),
  mathematiques(
    Color(0xFF3F8F7A),
    'assets/branding/subjects/icon_subject_mathematiques.png',
  ),
  questionnerLeMonde(
    Color(0xFF8A6BB0),
    'assets/branding/subjects/icon_subject_qlm.png',
  ),
  emc(Color(0xFFB0703E), 'assets/branding/subjects/icon_subject_emc.png'),
  eps(Color(0xFFC0504D), 'assets/branding/subjects/icon_subject_eps.png'),
  bcd(Color(0xFF8C7A5B), 'assets/branding/subjects/icon_subject_bcd.png'),
  specialiste(Color(0xFFB8BCC4), null); // gris clair hachuré, non modifiable

  const SubjectColor(this.color, this.iconAsset);
  final Color color;
  final String? iconAsset;
}

/// Fait correspondre un `subject_label` brut de l'EDT (§3.2 du plan) à sa couleur.
/// Reste volontairement permissif : un libellé inconnu retombe sur `specialiste`
/// plutôt que de faire planter l'écran Aujourd'hui.
SubjectColor subjectColorFor(String subjectLabel) {
  final normalized = subjectLabel.toLowerCase();
  if (normalized.contains('questionner le monde')) {
    return SubjectColor.questionnerLeMonde;
  }
  if (normalized.contains('bcd')) return SubjectColor.bcd;
  if (normalized.contains('emc')) return SubjectColor.emc;
  if (normalized.contains('eps')) return SubjectColor.eps;
  const francaisMots = [
    'rituels',
    'grammaire',
    'conjugaison',
    'phonologie',
    'dictée',
    'lecture',
    'production d\'écrits',
    'graphisme',
  ];
  if (francaisMots.any(normalized.contains)) return SubjectColor.francais;
  const mathsMots = [
    'numération',
    'géométrie',
    'calcul mental',
    'grandeurs',
    'résolution de problèmes',
  ];
  if (mathsMots.any(normalized.contains)) return SubjectColor.mathematiques;
  return SubjectColor.specialiste;
}
