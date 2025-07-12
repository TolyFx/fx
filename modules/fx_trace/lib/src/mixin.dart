import 'model/model.dart';
import 'trace/trace.dart';

typedef ExceptionCallback = void Function(Trace trace);

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
}

mixin TraceMixin {
  final List<ExceptionCallback> _actions = [];

  void addTraceListener(ExceptionCallback listener) {
    _actions.add(listener);
  }

  void removeTraceListener(ExceptionCallback listener) {
    _actions.remove(listener);
  }

  void dispose() {
    _actions.clear();
  }

  void notifyTrace(Trace trace) {
    if (trace is LogTrace) {
      bool isLowLevel = trace.level.index < FxTrace.minLogLevel.index;
      if (isLowLevel) return;
    }

    for (ExceptionCallback action in _actions) {
      try {
        action(trace);
      } catch (e) {
        // 防止单个监听器异常影响其他监听器
      }
    }
  }
}
