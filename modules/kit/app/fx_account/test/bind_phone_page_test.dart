import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fx_account/fx_account.dart';

void main() {
  testWidgets('手机号可用时发送验证码并提交绑定', (WidgetTester tester) async {
    String? requestedPhone;
    String? submittedPhone;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: FxAccountLocalizations.localizationsDelegates,
        supportedLocales: FxAccountLocalizations.supportedLocales,
        home: BindPhonePage(
          onValidatePhone: (String phone) async => true,
          onRequestCode: (String phone) async {
            requestedPhone = phone;
            return '123456';
          },
          onSubmit: (String phone, String code) async {
            submittedPhone = phone;
          },
        ),
      ),
    );

    final Finder fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '13800138000');
    await tester.tap(find.text('获取验证码'));
    await tester.pump();
    await tester.tap(find.text('确认绑定'));
    await tester.pump();

    expect(requestedPhone, '13800138000');
    expect(submittedPhone, '13800138000');
  });

  testWidgets('手机号被占用时不发送验证码', (WidgetTester tester) async {
    bool requested = false;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: FxAccountLocalizations.localizationsDelegates,
        supportedLocales: FxAccountLocalizations.supportedLocales,
        home: BindPhonePage(
          onValidatePhone: (String phone) async => false,
          onRequestCode: (String phone) async {
            requested = true;
            return null;
          },
          onSubmit: (String phone, String code) async {},
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, '13800138000');
    await tester.tap(find.text('获取验证码'));
    await tester.pump();

    expect(requested, isFalse);
  });
}
