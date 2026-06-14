import 'package:flutter_test/flutter_test.dart';
import 'package:fx_env/fx_env.dart';

void main() {
  group('OSChecker', () {
    test('android 识别为 mobile', () {
      final OSChecker checker = OSChecker(OS.android);
      expect(checker.isAndroid, isTrue);
      expect(checker.isMobile, isTrue);
      expect(checker.isDesktop, isFalse);
      expect(checker.isWeb, isFalse);
    });

    test('ios 识别为 mobile', () {
      final OSChecker checker = OSChecker(OS.ios);
      expect(checker.isIos, isTrue);
      expect(checker.isMobile, isTrue);
      expect(checker.isDesktop, isFalse);
    });

    test('ohos 识别为 mobile', () {
      final OSChecker checker = OSChecker(OS.ohos);
      expect(checker.isOhos, isTrue);
      expect(checker.isMobile, isTrue);
      expect(checker.isDesktop, isFalse);
    });

    test('windows 识别为 desktop', () {
      final OSChecker checker = OSChecker(OS.windows);
      expect(checker.isWindows, isTrue);
      expect(checker.isDesktop, isTrue);
      expect(checker.isDesktopUI, isTrue);
      expect(checker.isMobile, isFalse);
    });

    test('macos 识别为 desktop', () {
      final OSChecker checker = OSChecker(OS.macos);
      expect(checker.isMacOS, isTrue);
      expect(checker.isDesktop, isTrue);
      expect(checker.isDesktopUI, isTrue);
      expect(checker.isMobile, isFalse);
    });

    test('linux 识别为 desktop', () {
      final OSChecker checker = OSChecker(OS.linux);
      expect(checker.isLinux, isTrue);
      expect(checker.isDesktop, isTrue);
      expect(checker.isDesktopUI, isTrue);
      expect(checker.isMobile, isFalse);
    });

    test('web 不属于 desktop 也不属于 mobile', () {
      final OSChecker checker = OSChecker(OS.web);
      expect(checker.isWeb, isTrue);
      expect(checker.isDesktop, isFalse);
      expect(checker.isMobile, isFalse);
      expect(checker.isDesktopUI, isTrue);
    });

    test('unknown 不属于任何分类', () {
      final OSChecker checker = OSChecker(OS.unknown);
      expect(checker.isAndroid, isFalse);
      expect(checker.isIos, isFalse);
      expect(checker.isOhos, isFalse);
      expect(checker.isWindows, isFalse);
      expect(checker.isMacOS, isFalse);
      expect(checker.isLinux, isFalse);
      expect(checker.isWeb, isFalse);
      expect(checker.isDesktop, isFalse);
      expect(checker.isMobile, isFalse);
      expect(checker.isDesktopUI, isFalse);
    });
  });

  group('AppEnv', () {
    test('kApp 当前平台检测正常', () {
      // 在 Windows 测试环境下运行
      expect(kApp.os, isNotNull);
      expect(kApp.isWeb, isFalse);
    });
  });
}
