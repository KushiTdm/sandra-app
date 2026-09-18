import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/assistant/assistant_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/aujourdhui/aujourdhui_screen.dart';
import '../../features/classe/classe_screen.dart';
import '../../features/journal/journal_screen.dart';
import '../../features/reglages/reglages_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../shell/app_shell.dart';
import '../supabase/supabase_bootstrap.dart';
import 'go_router_refresh_stream.dart';

/// Un seul routeur pour toute l'app : la garde de connexion vit ici, jamais
/// dans un écran individuel. `redirect` est réévalué à chaque changement de
/// session grâce à `GoRouterRefreshStream` (sinon une déconnexion laisserait
/// l'écran précédent affiché jusqu'à une navigation manuelle).
final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = GoRouterRefreshStream(supabase.auth.onAuthStateChange);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      if (state.matchedLocation == '/splash') return null;
      final loggedIn = supabase.auth.currentSession != null;
      final loggingIn = state.matchedLocation == '/login';
      if (!loggedIn) return loggingIn ? null : '/login';
      if (loggingIn) return '/aujourdhui';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/aujourdhui',
                builder: (context, state) => const AujourdhuiScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/journal',
                builder: (context, state) => const JournalScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/classe',
                builder: (context, state) => const ClasseScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/assistant',
                builder: (context, state) => const AssistantScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/plus',
                builder: (context, state) => const ReglagesScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
