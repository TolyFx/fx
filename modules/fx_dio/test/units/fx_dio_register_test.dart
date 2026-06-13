import 'package:flutter_test/flutter_test.dart';
import 'package:fx_dio/fx_dio.dart';

import 'helper.dart';

void main() {
  setUp(() {
    FxDio().unregister(TestHost());
    FxDio().unregister(TestHost2());
  });

  group('FxDio 注册', () {
    test('register 成功', () {
      final TestHost host = TestHost();
      FxDio().register(host, options: const HostOptions(enableLog: false));
      final Dio dio = FxDio()[host];
      expect(dio.options.baseUrl, 'https://dev.example.com');
    });

    test('call 按类型查找', () {
      final TestHost host = TestHost();
      FxDio().register(host, options: const HostOptions(enableLog: false));
      final Host found = FxDio()<TestHost>();
      expect(found, host);
    });

    test('unregister 后查找为空', () {
      final TestHost host = TestHost();
      FxDio().register(host, options: const HostOptions(enableLog: false));
      FxDio().unregister(host);
      expect(
        () => FxDio()<TestHost>(),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('FxDio setTimeout', () {
    test('动态调整超时', () {
      final TestHost host = TestHost();
      FxDio().register(host, options: const HostOptions(enableLog: false));
      FxDio().setTimeout<TestHost>(
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 30),
      );
      final Dio dio = FxDio()[host];
      expect(dio.options.connectTimeout, const Duration(seconds: 60));
      expect(dio.options.receiveTimeout, const Duration(seconds: 30));
    });
  });

  group('FxDio rebase', () {
    test('更新已注册 Host 的 baseUrl', () {
      final TestHost host = TestHost();
      FxDio().register(host, options: const HostOptions(enableLog: false));
      final TestHost2 newHost = TestHost2();
      FxDio().rebase<TestHost>(newHost);
      final Dio dio = FxDio()[host];
      expect(dio.options.baseUrl, newHost.url);
    });
  });

  group('FxDio checkOptions', () {
    test('设置 method', () {
      final Options options = FxDio.checkOptions('POST', null);
      expect(options.method, 'POST');
    });

    test('保留已有 options', () {
      final Options original = Options(headers: {'X-Custom': 'value'});
      final Options options = FxDio.checkOptions('PUT', original);
      expect(options.method, 'PUT');
      expect(options.headers?['X-Custom'], 'value');
    });
  });
}
