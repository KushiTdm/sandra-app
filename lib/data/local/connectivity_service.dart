import 'package:connectivity_plus/connectivity_plus.dart';

/// `connectivity_plus` ne dit que si l'appareil tient une interface réseau —
/// pas si Internet répond réellement (faux positif possible sur un wifi sans
/// accès sortant). Sert donc de déclencheur pour tenter une synchronisation,
/// jamais de garantie : chaque appel réseau réel reste protégé par son propre
/// try/catch (voir `SyncService`, `VieDeClasseRepository`).
class ConnectivityService {
  ConnectivityService(this._connectivity);

  final Connectivity _connectivity;

  Future<bool> get isOnline async {
    final result = await _connectivity.checkConnectivity();
    return _hasConnection(result);
  }

  Stream<bool> get onlineChanges => _connectivity.onConnectivityChanged.map(_hasConnection);

  bool _hasConnection(List<ConnectivityResult> results) => results.any((r) => r != ConnectivityResult.none);
}
