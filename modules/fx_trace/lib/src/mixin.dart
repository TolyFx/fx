import 'package:fx_exception/fx_exception.dart';

import 'trace/log_trace.dart';

export 'package:fx_exception/fx_exception.dart' show TraceMixin, ExceptionCallback;

class FxTrace with TraceMixin {
  FxTrace._();

  static FxTrace? _instance;

  static LogLevel minLogLevel = LogLevel.info;

  factory FxTrace() {
    _instance ??= FxTrace._();
    return _instance!;
  }

  void emit(Trace trace) {
    notifyTrace(trace);
  }

  @override
  void notifyTrace(Trace trace) {
    if (trace is LogTrace) {
      bool isLowLevel = trace.level.index < FxTrace.minLogLevel.index;
      if (isLowLevel) return;
    }

    for (ExceptionCallback action in actions) {
      try {
        action(trace);
      } catch (_) {
        // 防止单个监听器异常影响其他监听器
      }
    }
  }
}
