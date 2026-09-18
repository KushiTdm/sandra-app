import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase/supabase_bootstrap.dart';

final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return supabase.auth.onAuthStateChange;
});

/// Session courante, dérivée du flux d'auth ; retombe sur `currentSession`
/// tant que le premier événement du flux n'est pas encore arrivé.
final currentSessionProvider = Provider<Session?>((ref) {
  final state = ref.watch(authStateChangesProvider).value;
  return state?.session ?? supabase.auth.currentSession;
});
