import '../model/model.dart';
import 'trace.dart';

/// 捕捉到的异常
class CatchTrace with Code, Trace {
  @override
  final StackTrace? stack;
  @override
  final Object? error;

  final String? msg;

  @override
  final int? value;

  CatchTrace(this.error, this.stack, {this.msg, this.value});

  @override
  Code? get code => this;

  @override
  String? get message => msg ?? error.toString();
}
