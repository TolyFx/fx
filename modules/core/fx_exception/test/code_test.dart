import 'package:flutter_test/flutter_test.dart';
import 'package:fx_exception/fx_exception.dart';

/// 验证用户自定义 Code mixin 能正常参与 Trace 体系
enum BizCode with Code {
  tokenExpired(401),
  notFound(404),
  ;

  @override
  final int code;

  const BizCode(this.code);
}

void main() {
  group('Code', () {
    test('自定义 Code 可作为 Trace.code 使用', () {
      final Trace trace = _FakeTrace(BizCode.tokenExpired);
      expect(trace.code.code, 401);
    });
  });
}

class _FakeTrace with Trace {
  @override
  final Code code;
  @override
  String? get message => null;
  @override
  Object? get error => null;
  @override
  StackTrace? get stack => null;

  _FakeTrace(this.code);
}
