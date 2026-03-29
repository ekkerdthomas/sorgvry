import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/media_repository.dart';
import 'db_providers.dart';

final mediaRepoProvider = Provider<MediaRepository>((ref) {
  return MediaRepository(
    db: ref.watch(healthDbProvider),
    deviceId: ref.watch(deviceIdProvider),
  );
});
