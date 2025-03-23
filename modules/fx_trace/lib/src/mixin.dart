import 'model/model.dart';

typedef ExceptionCallback = void Function(Trace trace);

class FxTrace with TraceMixin {
  FxTrace._();

  static FxTrace? _instance;

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

  LogLevel get logLevel => LogLevel.debug;

  void removeTraceListener(ExceptionCallback listener) {
    _actions.remove(listener);
  }

  void dispose() {
    _actions.clear();
  }

  void notifyTrace(Trace trace) {
    if (trace is LogTrace) {
      bool isLowLever = trace.level.index < logLevel.index;
      if (isLowLever) return;
    }

    for (ExceptionCallback action in _actions) {
      action(trace);
    }
  }
}
