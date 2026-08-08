import 'code.dart';

/// 异常追踪 mixin
mixin Trace {
  Code get code;
  String? get message;
  StackTrace? get stack;
  Object? get error;
}
