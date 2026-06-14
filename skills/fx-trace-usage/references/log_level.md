```dart
import 'package:fx_trace/fx_trace.dart';

// 设置全局日志级别 — 低于此级别的 LogTrace 不会触发 listener
FxTrace.minLogLevel = LogLevel.warning;

// 以下不会触发 listener（info < warning）
LogTrace('普通信息', level: LogLevel.info).emit();

// 以下会触发 listener
LogTrace('警告', level: LogLevel.warning).emit();
LogTrace('错误', level: LogLevel.error).emit();

// 注意：minLogLevel 只影响 LogTrace，TipTrace 和 CatchTrace 不受限制
TipTrace.info('这条始终会触发', 0).emit(); // ✅ 不受 minLogLevel 影响
```
