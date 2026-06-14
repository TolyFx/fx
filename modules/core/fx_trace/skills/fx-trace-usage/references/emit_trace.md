```dart
import 'package:fx_trace/fx_trace.dart';

// --- 日志 ---
LogTrace('页面加载完成').emit();
LogTrace('耗时 200ms', level: LogLevel.debug).emit();

// --- 提示 ---
TipTrace.info('操作成功', 0).emit();
TipTrace.warning('网络不稳定', 1001).emit();
TipTrace.error('保存失败', 2001).emit();
TipTrace.success('发布完成', 0).emit();

// --- 捕获异常 ---
try {
  final dynamic data = jsonDecode(raw);
} catch (e, s) {
  CatchTrace(e, s, msg: 'JSON 解析失败', code: 3001).emit();
}

// --- 自定义 Trace ---
class BizTrace with Trace {
  @override
  Code get code => _BizCode(bizCode);

  @override
  final String? message;

  @override
  Object? get error => null;

  @override
  StackTrace? get stack => null;

  final int bizCode;

  BizTrace(this.bizCode, this.message);
}
```
