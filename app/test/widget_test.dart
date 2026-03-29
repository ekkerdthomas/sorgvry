import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sorgvry/database/local_database.dart';
import 'package:sorgvry/main.dart';
import 'package:sorgvry/providers/db_providers.dart';
import 'package:sorgvry_shared/database/database.dart';

void main() {
  testWidgets('SorgvryApp renders', (tester) async {
    final healthDb = SorgvryDatabase(NativeDatabase.memory());
    final localDb = AppLocalDatabase(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          healthDbProvider.overrideWithValue(healthDb),
          localDbProvider.overrideWithValue(localDb),
        ],
        child: const SorgvryApp(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Sorgvry'), findsOneWidget);

    await healthDb.close();
    await localDb.close();
  });
}
