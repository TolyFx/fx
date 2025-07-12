
import '../model/model.dart';
import 'trace.dart';

enum TipLevel {
  info,
  warning,
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

  TipTrace.info(this.message, this.value) : level = TipLevel.info;
  TipTrace.warning(this.message, this.value) : level = TipLevel.warning;
  TipTrace.error(this.message, this.value) : level = TipLevel.error;
  TipTrace.success(this.message, this.value) : level = TipLevel.success;

  @override
  Code? get code => this;

  @override
  Object? get error => null;

  @override
  StackTrace? get stack => StackTrace.current;
}
