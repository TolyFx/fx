```dart
import 'package:fx_dio/fx_dio.dart';

/// 业务错误码
enum BizCode with Code {
  ok(0),
  tokenExpired(401),
  forbidden(403),
  notFound(10001),
  ;

  @override
  final int code;

  const BizCode(this.code);

  static BizCode fromInt(int value) {
    return BizCode.values.firstWhere(
      (BizCode e) => e.code == value,
      orElse: () => BizCode.ok,
    );
  }
}

/// 业务异常
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

  bool get isTokenExpired => code == BizCode.tokenExpired;
}

/// 业务 convertor：检测 code，非 0 抛出 BizException
T bizConvertor<T>(dynamic data, T Function(dynamic) parser) {
  if (data is Map<String, dynamic>) {
    final int code = data['code'] as int? ?? 0;
    if (code != 0) {
      throw BizException(
        BizCode.fromInt(code),
        data['message'] as String? ?? '',
      );
    }
    return parser(data['data']);
  }
  return parser(data);
}

/// 异常监听示例
void setupTraceListener() {
  FxDio().addTraceListener((Trace trace) {
    if (trace.error is BizException) {
      final BizException biz = trace.error! as BizException;
      if (biz.isTokenExpired) {
        // 跳转登录页
      }
    }
  });
}
```
