import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Date affichée par l'écran Aujourd'hui (navigable, pas forcément "aujourd'hui").
/// `StateProvider` a été déplacé vers `legacy.dart` en Riverpod 3 : un
/// `Notifier` avec des méthodes explicites est désormais la façon idiomatique
/// d'exposer un état mutable simple.
class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => _today();

  void shiftBy(int days) => state = state.add(Duration(days: days));

  void goToToday() => state = _today();

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}

final selectedDateProvider =
    NotifierProvider<SelectedDateNotifier, DateTime>(SelectedDateNotifier.new);
