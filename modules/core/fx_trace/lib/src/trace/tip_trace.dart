import 'package:fx_exception/fx_exception.dart';

enum TipLevel {
  info,
  warning,
  error,
  success,
}

class _SimpleCode with Code {
  @override
  final int code;
  const _SimpleCode(this.code);
}

/// 提示追踪
class TipTrace with Trace {
  final int _code;
  @override
  final String message;
  final TipLevel level;

  TipTrace(this.message, int code, {this.level = TipLevel.info}) : _code = code;

  TipTrace.info(this.message, int code) : _code = code, level = TipLevel.info;
  TipTrace.warning(this.message, int code) : _code = code, level = TipLevel.warning;
  TipTrace.error(this.message, int code) : _code = code, level = TipLevel.error;
  TipTrace.success(this.message, int code) : _code = code, level = TipLevel.success;

  @override
  Code get code => _SimpleCode(_code);

  @override
  Object? get error => null;

  @override
  StackTrace? get stack => StackTrace.current;
}
