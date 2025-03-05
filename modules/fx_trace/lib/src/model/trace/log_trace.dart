import '../model.dart';

enum LogLevel {
  none,
  info,
  debug,
  warning,
  error,
}

/// 捕捉到的异常
class LogTrace with Code, Trace {
  @override
  final int? value;

  @override
  final String message;

  final LogLevel level;

  LogTrace(this.message, this.value, {this.level = LogLevel.info});

  @override
  Code? get code => this;

  @override
  Object? get error => null;

  @override
  StackTrace? get stack => null;
}
