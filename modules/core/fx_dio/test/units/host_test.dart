import 'package:flutter_test/flutter_test.dart';

import 'helper.dart';

void main() {
  group('Host', () {
    test('url 拼接含 port 和 apiNest', () {
      final TestHost2 host = TestHost2();
      expect(host.url, 'https://api2.example.com:8080/api/v1');
    });

    test('同类型 Host 相等，不同类型不等', () {
      expect(TestHost() == TestHost(), isTrue);
      expect(TestHost() == TestHost2(), isFalse);
    });
  });
}
