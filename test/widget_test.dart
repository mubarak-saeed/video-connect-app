import 'package:flutter_test/flutter_test.dart';
import 'package:video_connect/main.dart';
import 'package:video_connect/core/app_constants.dart';

void main() {
  testWidgets('renders the V-Connect landing screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text('انضم'), findsOneWidget);
    expect(find.text('ابدأ'), findsOneWidget);
  });
}
