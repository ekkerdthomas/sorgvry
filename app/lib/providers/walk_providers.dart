import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/walk_repository.dart';
import 'db_providers.dart';

final walkRepoProvider = Provider<WalkRepository>((ref) {
  return WalkRepository(
    db: ref.watch(healthDbProvider),
    localDb: ref.watch(localDbProvider),
  );
});

final walkNotifierProvider = AsyncNotifierProvider<WalkNotifier, WalkState>(
  WalkNotifier.new,
);

class WalkNotifier extends AsyncNotifier<WalkState> {
  @override
  Future<WalkState> build() {
    return ref.watch(walkRepoProvider).todayStatus();
  }

  Future<void> save({required bool walked, int? durationMin}) async {
    await ref
        .read(walkRepoProvider)
        .saveWalk(walked: walked, durationMin: durationMin);
    state = AsyncData(await ref.read(walkRepoProvider).todayStatus());
  }
}
