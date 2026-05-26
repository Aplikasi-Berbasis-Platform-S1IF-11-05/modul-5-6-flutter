// This is a basic Flutter widget test for QEmailDomainApp.
import 'package:flutter_test/flutter_test.dart';
import 'package:qemail_fetcher/main.dart';

void main() {
  testWidgets('QEmail Domain App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const QEmailDomainApp());

    // Verify that the header title is rendered.
    expect(find.text('Domain Manager'), findsOneWidget);
    expect(find.text('QEMAIL'), findsOneWidget);
  });
}
