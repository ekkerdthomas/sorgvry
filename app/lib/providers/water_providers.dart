import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/water_repository.dart';
import 'db_providers.dart';

final waterRepoProvider = Provider<WaterRepository>((ref) {
  return WaterRepository(
    db: ref.watch(healthDbProvider),
    localDb: ref.watch(localDbProvider),
  );
});

final waterNotifierProvider = AsyncNotifierProvider<WaterNotifier, WaterState>(
  WaterNotifier.new,
);

class WaterNotifier extends AsyncNotifier<WaterState> {
  @override
  Future<WaterState> build() {
    return ref.watch(waterRepoProvider).todayStatus();
  }

  Future<void> setGlasses(int glasses) async {
    await ref.read(waterRepoProvider).setGlasses(glasses);
    state = AsyncData(await ref.read(waterRepoProvider).todayStatus());
  }
}
