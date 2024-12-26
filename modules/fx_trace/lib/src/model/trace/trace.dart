import '../model.dart';

mixin Trace {
  Code? get code;

  String? get message;

  StackTrace? get stack;

  Object? get error;
}
