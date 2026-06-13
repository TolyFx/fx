# fx_exception

Fx 家族统一异常追踪机制。提供 `Code`、`Trace`、`TraceMixin` 三个核心协议，各模块基于此扩展自己的异常体系。

## 核心概念

| 协议 | 职责 |
|------|------|
| `Code` | 错误码 mixin，任何 enum 通过 `with Code` 接入 |
| `Trace` | 异常信息 mixin，统一结构：code + message + error + stack |
| `TraceMixin` | 异常分发 mixin，支持多监听器 |

## 使用

```dart
import 'package:fx_exception/fx_exception.dart';
```

### 自定义错误码

```dart
enum BizCode with Code {
  tokenExpired(401),
  orderNotFound(10001),
  ;
  @override
  final int code;
  const BizCode(this.code);
}
```

### 自定义异常

```dart
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
```

### 监听异常

```dart
// 任何 with TraceMixin 的类都可以分发异常
class MyService with TraceMixin {
  void doSomething() {
    // ...
    notifyTrace(BizException(BizCode.tokenExpired, 'token 过期'));
  }
}

final service = MyService();
service.addTraceListener((trace) {
  print('${trace.code} - ${trace.message}');
});
```

## 内置

- `RequestErrorCode` — 框架级错误码（convert / emptyData / exception）
- `RequestException` — 请求异常，fx_dio 内部使用
- `kDefaultErrorHandler` — 默认 debug 日志输出
