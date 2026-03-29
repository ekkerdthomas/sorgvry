import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/bp_repository.dart';
import 'db_providers.dart';

final bpRepoProvider = Provider<BpRepository>((ref) {
  return BpRepository(
    db: ref.watch(healthDbProvider),
    localDb: ref.watch(localDbProvider),
  );
});

final bpNotifierProvider = AsyncNotifierProvider<BpNotifier, BpState>(
  BpNotifier.new,
);

class BpNotifier extends AsyncNotifier<BpState> {
  @override
  Future<BpState> build() {
    return ref.read(bpRepoProvider).todayStatus();
  }

  Future<void> save({required int systolic, required int diastolic}) async {
    await ref
        .read(bpRepoProvider)
        .saveReading(systolic: systolic, diastolic: diastolic);
    state = AsyncData(await ref.read(bpRepoProvider).todayStatus());
  }
}
