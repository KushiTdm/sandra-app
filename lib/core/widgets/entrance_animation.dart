import 'package:flutter/material.dart';

/// Fondu + léger glissement vertical à l'apparition, avec un décalage par
/// `index` pour un effet « en cascade » dans les listes (frise du jour,
/// liste d'élèves...). Une seule exécution par insertion du widget dans
/// l'arbre — pas de rejoue à chaque rebuild grâce à la clé fournie par
/// l'appelant (ex. `ValueKey(entry.id)`).
class EntranceAnimation extends StatefulWidget {
  const EntranceAnimation({
    super.key,
    required this.child,
    this.index = 0,
    this.duration = const Duration(milliseconds: 380),
    this.stagger = const Duration(milliseconds: 40),
    this.offset = 16,
  });

  final Widget child;
  final int index;
  final Duration duration;
  final Duration stagger;
  final double offset;

  @override
  State<EntranceAnimation> createState() => _EntranceAnimationState();
}

class _EntranceAnimationState extends State<EntranceAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );
  late final Animation<Offset> _slide = Tween(
    begin: Offset(0, widget.offset / 100),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    final delay = widget.stagger * widget.index;
    if (delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
