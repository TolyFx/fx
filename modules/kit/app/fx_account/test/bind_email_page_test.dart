import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fx_account/fx_account.dart';

void main() {
  testWidgets('绑定邮箱页发送验证码并将邮箱和验证码交给宿主', (WidgetTester tester) async {
    String? requestedEmail;
    String? submittedEmail;
    String? submittedCode;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: FxAccountLocalizations.localizationsDelegates,
        supportedLocales: FxAccountLocalizations.supportedLocales,
        home: BindEmailPage(
          resendCountdownSeconds: 1,
          onRequestCode: (String email) async {
            requestedEmail = email;
            return '123456';
          },
          onSubmit: (String email, String code) async {
            submittedEmail = email;
            submittedCode = code;
          },
        ),
      ),
    );

    final Finder fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'user@example.com');
    await tester.tap(find.text('获取验证码'));
    await tester.pump();
    await tester.tap(find.text('确认绑定'));
    await tester.pump();

    expect(requestedEmail, 'user@example.com');
    expect(submittedEmail, 'user@example.com');
    expect(submittedCode, '123456');
  });

  testWidgets('邮箱不可用时不请求验证码', (WidgetTester tester) async {
    bool requested = false;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: FxAccountLocalizations.localizationsDelegates,
        supportedLocales: FxAccountLocalizations.supportedLocales,
        home: BindEmailPage(
          onValidateEmail: (String email) async => false,
          onRequestCode: (String email) async {
            requested = true;
            return null;
          },
          onSubmit: (String email, String code) async {},
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'used@example.com');
    await tester.tap(find.text('获取验证码'));
    await tester.pump();

    expect(requested, isFalse);
  });
}
