import 'package:flutter_test/flutter_test.dart';

import 'package:custom_numeric_keyboard_demo/src/app.dart';

void main() {
  testWidgets('keyboard demo renders and switches mode', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CustomNumericKeyboardDemoApp());

    expect(find.text('自定义数字键盘'), findsOneWidget);
    expect(find.text('安全密码'), findsWidgets);
    expect(find.text('验证'), findsOneWidget);

    await tester.tap(find.text('金额输入').first);
    await tester.pumpAndSettle();

    expect(find.text('请输入金额'), findsOneWidget);
    expect(find.text('完成'), findsOneWidget);
  });
}
