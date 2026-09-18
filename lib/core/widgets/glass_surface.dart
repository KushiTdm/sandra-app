import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// Surface en verre dépoli façon Apple (flou + liseré translucide), utilisée
/// pour tout ce qui doit rester lisible en flottant au-dessus du contenu :
/// barre de navigation, bannière de synchronisation, bandeau « Proposé par
/// l'IA », en-têtes de fiche. Purement décoratif — n'ajoute aucun état.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(AppRadius.card)),
    this.blurSigma = 20,
    this.tint,
    this.borderColor,
    this.padding,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final double blurSigma;
  final Color? tint;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedTint =
        tint ?? (isDark ? AppColors.glassTintDark : AppColors.glassTintLight);
    final resolvedBorder =
        borderColor ??
        (isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight);

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: resolvedTint,
            borderRadius: borderRadius,
            border: Border.all(color: resolvedBorder, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Variante pleine largeur, sans coins arrondis — pour les barres flottantes
/// en haut/bas d'écran (bandeau hors-ligne, en-tête de fiche déroulante).
class GlassBar extends StatelessWidget {
  const GlassBar({
    super.key,
    required this.child,
    this.blurSigma = 24,
    this.tint,
  });

  final Widget child;
  final double blurSigma;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedTint =
        tint ?? (isDark ? AppColors.glassTintDark : AppColors.glassTintLight);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
      child: Container(color: resolvedTint, child: child),
    );
  }
}
