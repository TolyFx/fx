import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fx_trace/fx_trace.dart';

// 测试用异步事件
class TestAsyncEvent extends AsyncFxEvent<String> {
  final String input;
  TestAsyncEvent(this.input);
}

class TestAsyncIntEvent extends AsyncFxEvent<int> {
  final int value;
  TestAsyncIntEvent(this.value);
}

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

  group('AsyncFxEvent Tests', () {
    late StreamSubscription subscription;

    tearDown(() {
      subscription.cancel();
    });

    test('emitAsync should return result when completed', () async {
      // 模拟处理方
      subscription = FxEmitter().on<TestAsyncEvent>((event) {
        // 模拟异步处理
        Future.delayed(Duration(milliseconds: 50), () {
          event.complete('Hello ${event.input}');
        });
      });

      final event = TestAsyncEvent('World');
      final result = await event.emitAsync();

      expect(result, 'Hello World');
    });

    test('emitAsync should handle errors', () async {
      subscription = FxEmitter().on<TestAsyncEvent>((event) {
        event.completeError(Exception('Something went wrong'));
      });

      final event = TestAsyncEvent('test');

      expect(
        () => event.emitAsync(),
        throwsA(isA<Exception>()),
      );
    });

    test('emitAsync should timeout', () async {
      // 不调用 complete，让它超时
      subscription = FxEmitter().on<TestAsyncEvent>((event) {
        // 故意不处理
      });

      final event = TestAsyncEvent('test');

      expect(
        () => event.emitAsync(timeout: Duration(milliseconds: 100)),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('complete should only work once', () async {
      subscription = FxEmitter().on<TestAsyncIntEvent>((event) {
        event.complete(event.value * 2);
        event.complete(event.value * 3); // 第二次调用应该被忽略
      });

      final event = TestAsyncIntEvent(10);
      final result = await event.emitAsync();

      expect(result, 20); // 应该是第一次的结果
      expect(event.isCompleted, true);
    });

    test('should work with different return types', () async {
      subscription = FxEmitter().on<TestAsyncIntEvent>((event) {
        event.complete(event.value + 100);
      });

      final event = TestAsyncIntEvent(42);
      final result = await event.emitAsync();

      expect(result, 142);
    });
  });
}
