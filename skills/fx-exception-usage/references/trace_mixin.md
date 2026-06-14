```dart
import 'package:fx_exception/fx_exception.dart';

/// 任何类都可以 with TraceMixin 获得异常分发能力
class MyService with TraceMixin {
  void doWork() {
    try {
      // 业务逻辑...
      throw FormatException('bad data');
    } catch (e, stack) {
      notifyTrace(RequestException(RequestErrorCode.exception, '操作失败', e, stack));
    }
  }
}

/// 监听
void setupListeners() {
  final MyService service = MyService();

  service.addTraceListener((Trace trace) {
    print('[${trace.code.code}] ${trace.message}');
  });

  // 不再需要时移除
  // service.removeTraceListener(listener);
  // 或清空所有
  // service.dispose();
}
```
