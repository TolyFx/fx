import 'package:fx_trace/fx_trace.dart';

import '../model.dart';

mixin Trace implements Exception {
  Code? get code;

  String? get message;

  StackTrace? get stack;

  Object? get error;

  void emit() => FxTrace().emit(this);
}
