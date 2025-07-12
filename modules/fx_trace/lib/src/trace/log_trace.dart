import '../model/model.dart';
import 'trace.dart';

enum LogLevel {
  none,
  info,
  debug,
  warning,
  error,
}

/// 日志追踪
class LogTrace with Code, Trace {
  @override
  final int? value;

  final bool withStack;

  @override
  final String message;

  final LogLevel level;

  @override
  final StackTrace? stack;

  LogTrace(
    this.message, {
    this.level = LogLevel.info,
    this.value = 0,
    this.withStack = false,
  }) : stack = withStack ? StackTrace.current : null;

  @override
  Code? get code => this;

  @override
  Object? get error => null;

  @override
  String? get logString {
    String msg = "$runtimeType >> $message\n";
    String error = "Error#[${code?.value}]::${stack}";
    return "$msg$error";
  }
}
