import 'package:flutter_test/flutter_test.dart';
import 'package:accessally_ai/main.dart';
import 'package:accessally_ai/services/language_service.dart';

void main() {
  testWidgets('App launches and shows AccessAlly AI text', (WidgetTester tester) async {
    final languageService = LanguageService();
    await languageService.init();

    await tester.pumpWidget(AccessAllyApp(languageService: languageService));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('AccessAlly AI'), findsOneWidget);
  });
}