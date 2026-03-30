import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sorgvry_shared/database/database.dart';

import '../database/local_database.dart';
import '../services/sync_status.dart';

final healthDbProvider = Provider<SorgvryDatabase>(
  (ref) => throw UnimplementedError('Override healthDbProvider in main.dart'),
);

final localDbProvider = Provider<AppLocalDatabase>(
  (ref) => throw UnimplementedError('Override localDbProvider in main.dart'),
);

final deviceIdProvider = Provider<String>(
  (ref) => throw UnimplementedError('Override deviceIdProvider in main.dart'),
);

final syncStatusProvider = Provider<ValueNotifier<SyncStatus>>(
  (ref) => throw UnimplementedError('Override syncStatusProvider in main.dart'),
);
