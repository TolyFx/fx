import 'package:flutter_test/flutter_test.dart';
import 'package:fx_trace/fx_trace.dart';

void main() {
  group('FxTrace Tests', () {
    test('should emit and listen to traces', () {
      final traces = <Trace>[];
      FxTrace().addTraceListener((trace) => traces.add(trace));

      final logTrace = LogTrace('test message');
      logTrace.emit();

      expect(traces.length, 1);
      expect(traces.first.message, 'test message');
    });

    test('should respect log level filtering', () {
      FxTrace.minLogLevel = LogLevel.warning;
      final traces = <Trace>[];
      FxTrace().addTraceListener((trace) => traces.add(trace));

      LogTrace('info', level: LogLevel.info).emit();
      LogTrace('warning', level: LogLevel.warning).emit();

      expect(traces.length, 1);
      expect(traces.first.message, 'warning');
    });
  });
}
