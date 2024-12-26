import 'package:flutter/foundation.dart';

import 'trace.dart';


typedef ExceptionCallback = void Function(Trace trace);

void kDefaultErrorHandler(Trace trace) {
  if(kDebugMode){
    print("kDefaultHandler::${trace.code}::${trace.message}${trace.stack},");
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
    for (ExceptionCallback action in _actions) {
      action(trace);
    }
  }
}
