import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/classe/report_fab.dart';
import '../../features/classe/sync_status_banner.dart';
import '../widgets/glass_surface.dart';

/// Index de l'onglet Classe dans `destinations` ci-dessous — c'est le seul
/// endroit où le FAB « Signaler » apparaît (voir `floatingActionButton`).
const _classeTabIndex = 2;

/// Coquille commune aux 5 onglets (docs/prompts/claude_design_prompt.md) :
/// Aujourd'hui · Journal · Classe · Assistant · Plus, et le bandeau hors-ligne
/// (§3.5) toujours visible quel que soit l'onglet ouvert. La barre de
/// navigation flotte en verre dépoli au-dessus du contenu (le corps de chaque
/// écran s'étend derrière), façon barre d'onglets iOS.
///
/// Le FAB « Signaler » n'est visible que sur l'onglet Classe (demande de
/// Sandra du 16 septembre 2026) : affiché sur les 5 onglets, il se
/// superposait au champ de saisie de l'Assistant — sa position à l'écran
/// (bas-droite, au-dessus de la barre de navigation) est la même qu'avant,
/// seule sa présence sur les autres onglets a été retirée.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Column(
        children: [
          const SyncStatusBanner(),
          Expanded(child: navigationShell),
        ],
      ),
      floatingActionButton:
          navigationShell.currentIndex == _classeTabIndex ? const ReportFab() : null,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: GlassSurface(
          borderRadius: BorderRadius.circular(28),
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) => navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            ),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.today_outlined),
                selectedIcon: Icon(Icons.today),
                label: 'Aujourd\'hui',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book),
                label: 'Journal',
              ),
              NavigationDestination(
                icon: Icon(Icons.groups_outlined),
                selectedIcon: Icon(Icons.groups),
                label: 'Classe',
              ),
              NavigationDestination(
                icon: _AssistantTabIcon(selected: false),
                selectedIcon: _AssistantTabIcon(selected: true),
                label: 'Assistant',
              ),
              NavigationDestination(
                icon: Icon(Icons.more_horiz),
                selectedIcon: Icon(Icons.more_horiz),
                label: 'Plus',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Icône d'onglet Assistant dédiée (plutôt que `Icons.smart_toy`, trop
/// « robot » pour un assistant qui répond avec les données réelles de la
/// classe) — `NavigationBar` ne teinte que les `Icon`, pas les images, donc
/// la couleur sélectionné/non-sélectionné est reproduite ici à la main.
class _AssistantTabIcon extends StatelessWidget {
  const _AssistantTabIcon({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected
        ? scheme.onSecondaryContainer
        : scheme.onSurfaceVariant;
    return ColorFiltered(
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      child: Image.asset(
        'assets/branding/icon_assistant.png',
        width: 24,
        height: 24,
      ),
    );
  }
}
