import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fx_account/fx_account.dart';

void main() {
  testWidgets('注销页完成风险确认后将密码交给外部提交', (WidgetTester tester) async {
    String? submittedPassword;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: FxAccountLocalizations.localizationsDelegates,
        supportedLocales: FxAccountLocalizations.supportedLocales,
        home: DeleteAccountPage(
          onSubmit: (String password) async {
            submittedPassword = password;
          },
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'password');
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.text('确认注销').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('确认注销').last);
    await tester.pumpAndSettle();

    expect(submittedPassword, 'password');
  });
}
