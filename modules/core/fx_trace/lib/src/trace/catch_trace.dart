import 'package:fx_exception/fx_exception.dart';

class _SimpleCode with Code {
  @override
  final int code;
  const _SimpleCode(this.code);
}

/// 捕捉到的异常
class CatchTrace with Trace {
  @override
  final StackTrace? stack;
  @override
  final Object? error;

  final String? msg;

  final int _code;

  CatchTrace(this.error, this.stack, {this.msg, int code = 0}) : _code = code;

  @override
  Code get code => _SimpleCode(_code);

  @override
  String? get message => msg ?? error.toString();
}
