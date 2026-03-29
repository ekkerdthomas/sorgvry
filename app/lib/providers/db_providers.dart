import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sorgvry_shared/database/database.dart';

import '../database/local_database.dart';

final healthDbProvider = Provider<SorgvryDatabase>(
  (ref) => throw UnimplementedError('Override healthDbProvider in main.dart'),
);

final localDbProvider = Provider<AppLocalDatabase>(
  (ref) => throw UnimplementedError('Override localDbProvider in main.dart'),
);
