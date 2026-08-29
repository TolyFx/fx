import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fx_account/fx_account.dart';

void main() {
  testWidgets('修改密码页将最终输入交给外部提交', (WidgetTester tester) async {
    String? oldPassword;
    String? newPassword;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: FxAccountLocalizations.localizationsDelegates,
        supportedLocales: FxAccountLocalizations.supportedLocales,
        home: ChangePasswordPage(
          onSubmit: (String oldValue, String newValue) async {
            oldPassword = oldValue;
            newPassword = newValue;
          },
        ),
      ),
    );

    final Finder fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'old-password');
    await tester.enterText(fields.at(1), 'new-password');
    await tester.pump();
    await tester.tap(find.text('确认'));
    await tester.pump();

    expect(oldPassword, 'old-password');
    expect(newPassword, 'new-password');
  });

  testWidgets('提供找回回调时在底部展示并触发找回入口', (WidgetTester tester) async {
    bool opened = false;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: FxAccountLocalizations.localizationsDelegates,
        supportedLocales: FxAccountLocalizations.supportedLocales,
        home: ChangePasswordPage(
          onSubmit: (String oldValue, String newValue) async {},
          onForgotPassword: () => opened = true,
        ),
      ),
    );

    await tester.tap(find.text('忘记密码，立即找回？'));

    expect(opened, isTrue);
  });
}
