import 'trace.dart';

typedef ExceptionCallback = void Function(Trace trace);

/// 异常分发 mixin — 任何需要异常监听能力的类都可以 with
mixin TraceMixin {
  /// 已注册的异常监听器。
  final List<ExceptionCallback> _actions = [];

  /// 当前监听器的只读视图。
  List<ExceptionCallback> get actions => _actions;

  void addTraceListener(ExceptionCallback listener) {
    _actions.add(listener);
  }

  void removeTraceListener(ExceptionCallback listener) {
    _actions.remove(listener);
  }

  void dispose() {
    _actions.clear();
  }

  /// 分发异常，并隔离单个监听器的异常，避免阻断后续观察者。
  void notifyTrace(Trace trace) {
    final List<ExceptionCallback> listeners =
        List<ExceptionCallback>.from(_actions);
    for (final ExceptionCallback listener in listeners) {
      try {
        listener(trace);
      } catch (error, stackTrace) {
        onTraceListenerError(error, stackTrace);
      }
    }
  }

  /// 子类可重写以记录监听器错误；默认忽略，避免异常分发产生递归异常。
  void onTraceListenerError(Object error, StackTrace stackTrace) {}
}
