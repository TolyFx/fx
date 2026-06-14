import 'package:fx_exception/fx_exception.dart';

enum LogLevel {
  none,
  info,
  debug,
  warning,
  error,
}

class _SimpleCode with Code {
  @override
  final int code;
  const _SimpleCode(this.code);
}

/// 日志追踪
class LogTrace with Trace {
  final int _code;

  final bool withStack;

  @override
  final String message;

  final LogLevel level;

  @override
  final StackTrace? stack;

  LogTrace(
    this.message, {
    this.level = LogLevel.info,
    int code = 0,
    this.withStack = false,
  })  : _code = code,
        stack = withStack ? StackTrace.current : null;

  @override
  Code get code => _SimpleCode(_code);

  @override
  Object? get error => null;

  String? get logString {
    String msg = '$runtimeType >> $message\n';
    String err = 'Error#[$_code]::$stack';
    return '$msg$err';
  }
}
