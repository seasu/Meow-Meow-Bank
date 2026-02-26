import 'package:flutter_test/flutter_test.dart';
import 'package:meow_meow_bank/main.dart';

void main() {
  testWidgets('App renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(const MeowMeowBankApp());
    expect(find.text('🏦 喵喵金幣屋'), findsOneWidget);
  });
}
