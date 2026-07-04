import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sorgvry/database/local_database.dart';
import 'package:sorgvry/providers/bp_providers.dart';
import 'package:sorgvry/providers/daily_refresh.dart';
import 'package:sorgvry/providers/db_providers.dart';
import 'package:sorgvry/providers/meds_providers.dart';
import 'package:sorgvry/providers/walk_providers.dart';
import 'package:sorgvry/providers/water_providers.dart';
import 'package:sorgvry/repositories/bp_repository.dart';
import 'package:sorgvry/repositories/meds_repository.dart';
import 'package:sorgvry/repositories/walk_repository.dart';
import 'package:sorgvry/repositories/water_repository.dart';
import 'package:sorgvry_shared/database/database.dart';

void main() {
  const deviceId = 'test-device';

  test(
    'invalidating a daily notifier re-runs todayStatus against the DB',
    () async {
      final healthDb = SorgvryDatabase(NativeDatabase.memory());
      final localDb = AppLocalDatabase(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [
          healthDbProvider.overrideWithValue(healthDb),
          localDbProvider.overrideWithValue(localDb),
          deviceIdProvider.overrideWithValue(deviceId),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await healthDb.close();
        await localDb.close();
      });

      // Log this morning's meds, then read the cached "today" state.
      await container
          .read(medsRepoProvider)
          .confirmMeds(session: 'morning', taken: true);
      final before = await container.read(medsNotifierProvider.future);
      expect(before.morningTaken, isTrue);

      // Simulate a fresh day: today's rows no longer exist.
      await healthDb.delete(healthDb.medLogs).go();

      // Invalidation forces build() -> todayStatus() to run again.
      container.invalidate(medsNotifierProvider);
      final after = await container.read(medsNotifierProvider.future);
      expect(after.morningTaken, isFalse);
    },
  );

  testWidgets('refreshDailyProviders resets all four daily modules', (
    tester,
  ) async {
    final healthDb = SorgvryDatabase(NativeDatabase.memory());
    final localDb = AppLocalDatabase(NativeDatabase.memory());
    addTearDown(() async {
      await healthDb.close();
      await localDb.close();
    });

    // Seed today's data for every module via their repositories.
    await MedsRepository(
      db: healthDb,
      localDb: localDb,
      deviceId: deviceId,
    ).confirmMeds(session: 'morning', taken: true);
    await BpRepository(
      db: healthDb,
      localDb: localDb,
      deviceId: deviceId,
    ).saveReading(systolic: 120, diastolic: 80);
    await WaterRepository(
      db: healthDb,
      localDb: localDb,
      deviceId: deviceId,
    ).setGlasses(8);
    await WalkRepository(
      db: healthDb,
      localDb: localDb,
      deviceId: deviceId,
    ).saveWalk(walked: true, durationMin: 30);

    late WidgetRef ref;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          healthDbProvider.overrideWithValue(healthDb),
          localDbProvider.overrideWithValue(localDb),
          deviceIdProvider.overrideWithValue(deviceId),
        ],
        child: Consumer(
          builder: (context, r, _) {
            ref = r;
            // Watch all four so they build and stay alive.
            r.watch(medsNotifierProvider);
            r.watch(bpNotifierProvider);
            r.watch(waterNotifierProvider);
            r.watch(walkNotifierProvider);
            return const SizedBox();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Sanity: every module reports "done" for today.
    expect(ref.read(medsNotifierProvider).value?.morningTaken, isTrue);
    expect(ref.read(bpNotifierProvider).value?.hasReading, isTrue);
    expect(ref.read(waterNotifierProvider).value?.glasses, 8);
    expect(ref.read(walkNotifierProvider).value?.walked, isTrue);

    // The day rolls over: today's rows are gone.
    await healthDb.delete(healthDb.medLogs).go();
    await healthDb.delete(healthDb.bpReadings).go();
    await healthDb.delete(healthDb.waterLogs).go();
    await healthDb.delete(healthDb.walkLogs).go();

    refreshDailyProviders(ref);
    await tester.pumpAndSettle();

    // Every module has reset to its empty state.
    expect(ref.read(medsNotifierProvider).value?.morningTaken, isFalse);
    expect(ref.read(bpNotifierProvider).value?.hasReading, isFalse);
    expect(ref.read(waterNotifierProvider).value?.glasses, 0);
    expect(ref.read(walkNotifierProvider).value?.walked, isFalse);
  });
}
