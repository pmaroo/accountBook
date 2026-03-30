// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fittheweb_household/app/app_controller.dart';
import 'package:fittheweb_household/main.dart';
import 'package:fittheweb_household/data/local/memory_app_storage.dart';

void main() {
  testWidgets('renders the household finance shell', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MoneyBookApp(
        controllerFuture: AppController.create(storage: MemoryAppStorage()),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.text('가계부'), findsOneWidget);
    expect(find.text('이번 달 총 저축 가능 금액'), findsOneWidget);
    expect(find.text('홈'), findsOneWidget);
    expect(find.text('통계'), findsOneWidget);
  });
}
