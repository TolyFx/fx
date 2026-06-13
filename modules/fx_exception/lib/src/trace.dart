import 'code.dart';

/// 异常追踪 mixin
mixin Trace {
  Code get code;
  String? get message;
  StackTrace? get stack;
  Object? get error;
}

/// 请求异常
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

  @override
  String toString() => 'RequestException: [${code.name}#${code.code}] $message';
}

/// 框架级错误码
enum RequestErrorCode with Code {
  convert(0),
  emptyData(1),
  exception(2),
  ;

  @override
  final int code;

  const RequestErrorCode(this.code);
}
