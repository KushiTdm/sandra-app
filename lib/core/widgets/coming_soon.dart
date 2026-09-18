import 'package:flutter/material.dart';

import 'empty_state.dart';

/// Écran de repli pour un onglet dont l'écran réel n'est pas encore construit,
/// en attendant le lot correspondant du plan.
class ComingSoon extends StatelessWidget {
  const ComingSoon({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return EmptyState(icon: icon, title: title, description: description);
  }
}
