import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'signalement_sheet.dart';

/// FAB « Signaler » (docs/prompts/claude_design_prompt.md, écran 4) : ouvre
/// le signalement rapide multi-élèves avec dictée vocale (§6.3). Affiché
/// uniquement sur l'onglet Classe (`AppShell` — plus sur les 5 onglets comme
/// à l'origine) : il se superposait au champ de saisie de l'Assistant,
/// signalé par Sandra le 16 septembre 2026.
///
/// Volontairement compact (icône seule, 44 px) : la version étendue
/// « 🏳 Signaler » masquait le contenu des écrans, notamment le dernier
/// élève de l'appel et le dernier créneau d'Aujourd'hui (constaté en
/// conditions réelles). L'intitulé reste accessible en appui long.
class ReportFab extends StatelessWidget {
  const ReportFab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.accent, Color(0xFFB2502B)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.28),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => showSignalementSheet(context),
          child: Tooltip(
            message: 'Signaler un élève',
            child: const Icon(Icons.flag_outlined, size: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
