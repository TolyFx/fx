import 'package:flutter_test/flutter_test.dart';
import 'package:fx_exception/fx_exception.dart';

/// 用户自定义异常
enum BizCode with Code {
  serverError(500),
  ;

  @override
  final int code;

  const BizCode(this.code);
}

class BizException with Trace implements Exception {
  @override
  final BizCode code;
  @override
  final String? message;
  @override
  final Object? error;
  @override
  final StackTrace? stack;

  BizException(this.code, this.message, [this.error, this.stack]);
}

void main() {
  group('Trace', () {
    test('RequestException.toString 包含关键信息', () {
      final RequestException e =
          RequestException(RequestErrorCode.emptyData, 'no data');
      final String str = e.toString();
      expect(str, contains('emptyData'));
      expect(str, contains('no data'));
    });

    test('用户自定义异常符合 Trace 协议', () {
      final BizException e = BizException(BizCode.serverError, '服务器错误');
      // 能赋值给 Trace 类型，说明协议满足
      final Trace trace = e;
      expect(trace.code.code, 500);
      expect(trace.message, '服务器错误');
    });
  });
}
