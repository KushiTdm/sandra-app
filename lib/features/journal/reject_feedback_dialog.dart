import 'package:flutter/material.dart';

/// Boîte de rejet avec indication facultative (Sandra, 16 septembre 2026) :
/// au moment de rejeter une proposition de l'IA — séance ou fiche
/// d'exercices — pouvoir dire pourquoi ou ce qu'elle voudrait à la place,
/// plutôt que de devoir retrouver le créneau vide ailleurs pour relancer une
/// génération à la main. Partagée entre `GenerationValidationScreen` et
/// `_ExercicesSheet` : même dialogue, même contrat (renvoie `null` si
/// annulé, une chaîne vide pour un rejet simple, un texte pour un rejet
/// motivé qui doit déclencher une regénération).
class RejectFeedbackDialog extends StatefulWidget {
  const RejectFeedbackDialog({super.key});

  @override
  State<RejectFeedbackDialog> createState() => _RejectFeedbackDialogState();
}

class _RejectFeedbackDialogState extends State<RejectFeedbackDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rejeter cette proposition'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pourquoi, ou qu\'aimeriez-vous à la place ? Si vous répondez, '
            'l\'IA prépare aussitôt une nouvelle proposition en tenant compte '
            'de votre remarque.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Facultatif — laissez vide pour un simple rejet.',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // null : annuler
          child: const Text('Annuler'),
        ),
        // Un seul bouton de confirmation : l'appelant décide lui-même de
        // regénérer ou non selon que le champ est resté vide — plus simple
        // qu'un second bouton dont l'activation dépendrait du texte saisi.
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Rejeter'),
        ),
      ],
    );
  }
}
