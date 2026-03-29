import 'package:flutter_test/flutter_test.dart';
import 'package:sorgvry/main.dart';

void main() {
  testWidgets('SorgvryApp renders', (tester) async {
    await tester.pumpWidget(const SorgvryApp());
    expect(find.text('Sorgvry'), findsOneWidget);
  });
}
