```dart
import 'package:fx_exception/fx_exception.dart';

/// 自定义业务错误码
enum BizCode with Code {
  tokenExpired(401),
  forbidden(403),
  notFound(10001),
  paymentFailed(10002),
  ;

  @override
  final int code;

  const BizCode(this.code);
}
```
