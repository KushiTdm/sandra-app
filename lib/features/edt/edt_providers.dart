import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/supabase/supabase_bootstrap.dart';
import '../../data/repositories/edt_repository.dart';
import '../../models/schedule_slot.dart';

final edtRepositoryProvider = Provider<EdtRepository>((ref) => EdtRepository(supabase));

final currentClassIdProvider = FutureProvider.autoDispose<String>((ref) {
  return ref.watch(edtRepositoryProvider).currentClassId();
});

final currentVersionProvider =
    FutureProvider.autoDispose<({String id, String label, DateTime validFrom})>((ref) async {
  final classId = await ref.watch(currentClassIdProvider.future);
  return ref.watch(edtRepositoryProvider).currentVersion(classId);
});

final currentSlotsProvider = FutureProvider.autoDispose<List<ScheduleSlot>>((ref) async {
  final version = await ref.watch(currentVersionProvider.future);
  return ref.watch(edtRepositoryProvider).slotsForVersion(version.id);
});

final entriesToRelocateProvider = FutureProvider.autoDispose<List<EntryToRelocate>>((ref) {
  return ref.watch(edtRepositoryProvider).entriesToRelocate();
});

final knownDomainCodesProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final classId = await ref.watch(currentClassIdProvider.future);
  return ref.watch(edtRepositoryProvider).knownDomainCodes(classId);
});
