import 'dart:async';

import 'package:flutter/foundation.dart';

/// Transforme un flux (ici : les changements d'état d'auth Supabase) en
/// `Listenable`, pour que `GoRouter` recalcule ses redirections dès que la
/// session change — sans quoi une connexion/déconnexion resterait affichée
/// sur le mauvais écran jusqu'à une navigation manuelle.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
