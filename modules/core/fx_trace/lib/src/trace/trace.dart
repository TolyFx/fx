import 'package:fx_exception/fx_exception.dart' as exc;

import '../../fx_trace.dart';

export 'package:fx_exception/fx_exception.dart' show Code, Trace;
export 'tip_trace.dart';
export 'log_trace.dart';
export 'catch_trace.dart';

/// 为 fx_exception 的 Trace 扩展 emit 便捷方法
extension TraceEmitExt on exc.Trace {
  void emit() => FxTrace().emit(this);
}
