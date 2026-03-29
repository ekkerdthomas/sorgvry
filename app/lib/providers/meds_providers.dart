import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/meds_repository.dart';
import 'db_providers.dart';

final medsRepoProvider = Provider<MedsRepository>((ref) {
  return MedsRepository(
    db: ref.watch(healthDbProvider),
    localDb: ref.watch(localDbProvider),
  );
});

final medsNotifierProvider = AsyncNotifierProvider<MedsNotifier, MedsState>(
  MedsNotifier.new,
);

class MedsNotifier extends AsyncNotifier<MedsState> {
  @override
  Future<MedsState> build() {
    return ref.watch(medsRepoProvider).todayStatus();
  }

  Future<void> confirm(String session) async {
    await ref.read(medsRepoProvider).confirmMeds(session: session, taken: true);
    state = AsyncData(await ref.read(medsRepoProvider).todayStatus());
  }

  Future<bool> undo(String session) async {
    final success = await ref.read(medsRepoProvider).undoMeds(session);
    if (success) {
      state = AsyncData(await ref.read(medsRepoProvider).todayStatus());
    }
    return success;
  }
}
