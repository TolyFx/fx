import 'package:flutter_test/flutter_test.dart';
import 'package:fx_trace/fx_trace.dart';

void main() {
  group('FxTrace', () {
    test('emit 和 listener 正常工作', () {
      final List<Trace> traces = [];
      FxTrace().addTraceListener((Trace trace) => traces.add(trace));

      final LogTrace logTrace = LogTrace('test message');
      FxTrace().emit(logTrace);

      expect(traces.length, 1);
      expect(traces.first.message, 'test message');
    });

    test('日志级别过滤', () {
      FxTrace.minLogLevel = LogLevel.warning;
      final List<Trace> traces = [];
      FxTrace().addTraceListener((Trace trace) => traces.add(trace));

      FxTrace().emit(LogTrace('info', level: LogLevel.info));
      FxTrace().emit(LogTrace('warning', level: LogLevel.warning));

      expect(traces.length, 1);
      expect(traces.first.message, 'warning');
    });
  });

  group('CatchTrace', () {
    test('捕获异常信息', () {
      final CatchTrace trace = CatchTrace(
        const FormatException('bad'),
        StackTrace.current,
        msg: 'parse failed',
        code: 100,
      );
      expect(trace.message, 'parse failed');
      expect(trace.code.value, 100);
    });

    test('msg 为空时回退到 error.toString', () {
      final CatchTrace trace = CatchTrace(
        const FormatException('oops'),
        null,
      );
      expect(trace.message, contains('FormatException'));
    });
  });

  group('TipTrace', () {
    test('各 level 构造正确', () {
      final TipTrace info = TipTrace.info('msg', 0);
      final TipTrace warning = TipTrace.warning('msg', 1);
      final TipTrace error = TipTrace.error('msg', 2);
      final TipTrace success = TipTrace.success('msg', 3);

      expect(info.level, TipLevel.info);
      expect(warning.level, TipLevel.warning);
      expect(error.level, TipLevel.error);
      expect(success.level, TipLevel.success);
    });
  });
}
