import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../core/supabase/supabase_bootstrap.dart';
import '../../core/theme/app_colors.dart';

/// Écran de lancement animé : rejoue le générique LFAY (dessin du logo,
/// 4 s, muet) juste après le splash natif Android, puis enchaîne vers
/// Aujourd'hui ou Connexion selon la session en cours. Le `redirect` du
/// routeur (app_router.dart) reste la seule source de vérité sur la
/// destination finale — cet écran ne fait que proposer une navigation,
/// jamais de logique d'authentification.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final VideoPlayerController _controller;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/branding/lfay_intro.mp4')
      ..setVolume(0)
      ..initialize()
          .then((_) {
            if (!mounted) return;
            setState(() {});
            _controller.play();
          })
          .catchError((_) {
            // Asset vidéo indisponible sur cet appareil (codec, etc.) : on ne
            // bloque jamais l'accès à l'app pour un générique manqué.
            _goNext();
          });
    _controller.addListener(_onTick);
    // Filet de sécurité si la vidéo ne se termine jamais (ex. bug de codec).
    Future.delayed(const Duration(seconds: 6), _goNext);
  }

  void _onTick() {
    final value = _controller.value;
    if (value.isInitialized &&
        !value.isPlaying &&
        value.position >= value.duration &&
        value.duration > Duration.zero) {
      _goNext();
    }
  }

  void _goNext() {
    if (_navigated || !mounted) return;
    _navigated = true;
    final loggedIn = supabase.auth.currentSession != null;
    context.go(loggedIn ? '/aujourdhui' : '/login');
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: GestureDetector(
        // Un tap saute directement le générique — utile en classe, pressée.
        onTap: _goNext,
        child: _controller.value.isInitialized
            // Générique en plein écran, quitte à rogner les côtés (choix de
            // Sandra) : `BoxFit.cover` remplit l'écran en gardant le ratio de
            // la vidéo, la découpe se faisant sur la dimension excédentaire.
            // La vidéo est donnée à `FittedBox` à sa taille native — sans
            // cela, `VideoPlayer` prend la taille de son parent et il n'y a
            // plus aucun ratio à préserver.
            ? SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              )
            : const SizedBox.expand(),
      ),
    );
  }
}
