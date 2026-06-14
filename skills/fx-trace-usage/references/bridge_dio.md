```dart
import 'package:fx_dio/fx_dio.dart';
import 'package:fx_trace/fx_trace.dart';

/// 在 App 初始化时桥接 fx_dio → FxTrace
/// 桥接后，所有网络异常自动进入 FxTrace 的全局 listener
void initTraceBridge() {
  FxDio().addTraceListener((Trace trace) => FxTrace().emit(trace));
}

/// 统一监听示例 — 网络异常和应用日志在同一处处理
void initGlobalListener() {
  FxTrace().addTraceListener((Trace trace) {
    if (trace is RequestException) {
      // 网络层异常
      print('网络错误: [${trace.code.value}] ${trace.message}');
    } else if (trace is TipTrace) {
      // 业务提示
      print('提示: ${trace.message}');
    } else if (trace is LogTrace) {
      // 日志
      print('日志: ${trace.message}');
    }
  });
}
```
