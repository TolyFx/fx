import 'package:test/test.dart';
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

/// 验证通用异常基类可被模块直接继承。
final class TypedBizException extends FxException<BizCode> {
  const TypedBizException(
    super.code,
    super.message, [
    super.error,
    super.stack,
  ]);
}

void main() {
  group('Trace', () {
    test('通用异常基类保留模块错误码和根因', () {
      const FormatException cause = FormatException('格式错误');
      const TypedBizException exception = TypedBizException(
        BizCode.serverError,
        '服务不可用',
        cause,
      );

      expect(exception.code, BizCode.serverError);
      expect(exception.message, '服务不可用');
      expect(exception.error, cause);
    });

    test('RequestException.toString 包含关键信息', () {
      const RequestException e =
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
