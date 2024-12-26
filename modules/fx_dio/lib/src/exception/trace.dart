import '../code/code.dart';

mixin Trace {
  Code get code;

  String? get message;

  StackTrace? get stack;

  Object? get error;
}

class RequestException with Trace implements Exception {
  @override
  final RequestErrorCode code;

  @override
  final String? message;

  @override
  final StackTrace? stack;

  @override
  final Object? error;

  RequestException(
    this.code,
    this.message, [
    this.error,
    this.stack,
  ]);
}

enum RequestErrorCode with Code {
  convert(0),
  emptyData(1),
  exception(2),
  ;

  @override
  final int code;

  const RequestErrorCode(this.code);
}
