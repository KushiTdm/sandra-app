import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_surface.dart';
import 'vie_de_classe_providers.dart';

/// Bandeau visible sur les 5 onglets (§3.5, Lot 4) : Sandra doit toujours
/// pouvoir voir, sans aller chercher, si elle est hors connexion et si
/// l'appel/un signalement/un bilan attend encore d'être synchronisé.
/// Silencieux dès que tout est à jour — pas de bruit visuel le reste du temps.
class SyncStatusBanner extends ConsumerWidget {
  const SyncStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider).value ?? true;
    final pendingCount = ref.watch(pendingSyncCountProvider).value ?? 0;

    if (isOnline && pendingCount == 0) return const SizedBox.shrink();

    final String label;
    if (!isOnline && pendingCount > 0) {
      label = 'Hors connexion — $pendingCount élément${pendingCount > 1 ? 's' : ''} en attente';
    } else if (!isOnline) {
      label = 'Hors connexion — les saisies restent enregistrées sur l\'appareil';
    } else {
      label = 'Synchronisation en cours — $pendingCount élément${pendingCount > 1 ? 's' : ''} en attente';
    }

    final tint = isOnline
        ? AppColors.masteryEnCours.withValues(alpha: 0.22)
        : AppColors.masteryFragile.withValues(alpha: 0.24);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: GlassBar(
        key: ValueKey('$isOnline-$pendingCount'),
        tint: tint,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  isOnline ? Icons.sync : Icons.cloud_off_outlined,
                  size: 18,
                  color: AppColors.ink,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.ink)),
                ),
                if (pendingCount > 0)
                  IconButton(
                    tooltip: 'Réessayer maintenant',
                    icon: const Icon(Icons.refresh, size: 18),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => ref.read(syncServiceProvider).syncNow(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
