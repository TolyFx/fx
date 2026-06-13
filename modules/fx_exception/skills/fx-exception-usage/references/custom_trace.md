```dart
import 'package:fx_exception/fx_exception.dart';

/// 自定义业务异常
class BizException with Trace implements Exception {
  @override
  final Code code;
  @override
  final String? message;
  @override
  final Object? error;
  @override
  final StackTrace? stack;

  BizException(this.code, this.message, [this.error, this.stack]);
}

/// 用法
void example() {
  final BizException e = BizException(BizCode.tokenExpired, 'token 已过期');

  // 符合 Trace 协议，可直接传入 TraceMixin.notifyTrace
  final Trace trace = e;
  print('${trace.code.code}: ${trace.message}');
}
```
