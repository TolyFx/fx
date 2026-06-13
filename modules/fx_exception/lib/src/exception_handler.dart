import 'package:flutter/foundation.dart';

import 'trace.dart';

typedef ExceptionCallback = void Function(Trace trace);

void kDefaultErrorHandler(Trace trace) {
  assert(() {
    debugPrint("FxException::${trace.code}::${trace.message}");
    return true;
  }());
}

/// 异常分发 mixin — 任何需要异常监听能力的类都可以 with
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
    for (ExceptionCallback action in _actions) {
      action(trace);
    }
  }
}
