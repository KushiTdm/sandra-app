import 'package:flutter/material.dart';

import 'entrance_animation.dart';

/// État vide sobre et cohérent avec l'identité LFAY (docs/prompts/
/// claude_design_prompt.md, écran 22) : par défaut, le motif du pavillon du
/// logo de l'école en filigrane avec un badge d'icône contextuelle en
/// surimpression. Un [illustration] dédié (ex. la salle de classe dessinée
/// dans assets/branding/onboarding_premiere_classe.png, ou l'icône Assistant)
/// peut remplacer ce visuel générique pour les cas qui le méritent — jamais
/// de mascotte ni d'illustration clipart (charte du prompt maquettes).
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.action,
    this.illustration,
  });

  final IconData icon;
  final String title;
  final String? description;
  final Widget? action;
  final Widget? illustration;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outline;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: EntranceAnimation(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              illustration ?? _DefaultMark(icon: icon, outline: outline),
              const SizedBox(height: 20),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              if (description != null) ...[
                const SizedBox(height: 8),
                Text(
                  description!,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: outline),
                  textAlign: TextAlign.center,
                ),
              ],
              if (action != null) ...[const SizedBox(height: 20), action!],
            ],
          ),
        ),
      ),
    );
  }
}

class _DefaultMark extends StatelessWidget {
  const _DefaultMark({required this.icon, required this.outline});

  final IconData icon;
  final Color outline;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 104,
      height: 104,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.3,
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(outline, BlendMode.srcIn),
              child: Image.asset('assets/branding/lfay_mark.png', width: 104),
            ),
          ),
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(icon, size: 22, color: outline),
            ),
          ),
        ],
      ),
    );
  }
}

/// Illustration pleine (salle de classe, générique Assistant...) à taille
/// fixe, prête à passer en `illustration:` à [EmptyState].
class EmptyStateIllustration extends StatelessWidget {
  const EmptyStateIllustration({
    super.key,
    required this.asset,
    this.tint,
    this.size = 140,
  });

  final String asset;
  final Color? tint;
  final double size;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(asset, width: size);
    return SizedBox(
      width: size,
      height: size,
      child: tint == null
          ? image
          : ColorFiltered(
              colorFilter: ColorFilter.mode(tint!, BlendMode.srcIn),
              child: image,
            ),
    );
  }
}
