import '../../fx_trace.dart';

export 'tip_trace.dart';
export 'log_trace.dart';
export 'catch_trace.dart';

mixin Trace implements Exception {
  Code? get code;

  String? get message;

  StackTrace? get stack;

  Object? get error;

  void emit() => FxTrace().emit(this);

  String? get logString => null;

  @override
  String toString() {
    int? v = code?.value;
    String result = '';
    if (v != null) {
      result += '[$v]:';
    }
    if (message != null) {
      result += message!;
    }
    return '$result error:$error';
  }
}
