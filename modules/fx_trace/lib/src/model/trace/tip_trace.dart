import '../model.dart';

enum TipLevel {
  info,
  waring,
  error,
  success,
}

/// 捕捉到的异常
class TipTrace with Code, Trace {
  @override
  final int? value;
  @override
  final String message;
  final TipLevel level;

  TipTrace(this.message, this.value, {this.level = TipLevel.info});

  @override
  Code? get code => this;

  @override
  Object? get error => null;

  @override
  StackTrace? get stack => null;
}
