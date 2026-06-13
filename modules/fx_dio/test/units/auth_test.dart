import 'package:flutter_test/flutter_test.dart';
import 'package:fx_dio/fx_dio.dart';

void main() {
  group('BearerTokenAuth', () {
    test('buildHeaders 包含正确的 Authorization', () {
      final BearerTokenAuth auth = BearerTokenAuth(token: 'abc123');
      expect(auth.buildHeaders['Authorization'], 'Bearer abc123');
    });
  });
}
