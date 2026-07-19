import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fx_event/fx_event.dart';

import 'helper.dart';

void main() {
  group('AsyncFxEvent', () {
    late StreamSubscription<FxEvent> subscription;

    tearDown(() {
      subscription.cancel();
    });

    test('emitAsync 返回处理结果', () async {
      subscription = FxEmitter().on<TestAsyncEvent>((TestAsyncEvent event) {
        Future<void>.delayed(const Duration(milliseconds: 10), () {
          event.complete('Hi ${event.input}');
        });
      });

      final TestAsyncEvent event = TestAsyncEvent('World');
      final String result = await event.emitAsync();
      expect(result, 'Hi World');
    });

    test('emitAsync 超时', () async {
      subscription = FxEmitter().on<TestAsyncEvent>((TestAsyncEvent event) {
        // 故意不 complete
      });

      final TestAsyncEvent event = TestAsyncEvent('timeout');
      expect(
        () => event.emitAsync(timeout: const Duration(milliseconds: 50)),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('complete 只生效一次', () async {
      subscription = FxEmitter().on<TestAsyncEvent>((TestAsyncEvent event) {
        event.complete('first');
        event.complete('second');
      });

      final TestAsyncEvent event = TestAsyncEvent('test');
      final String result = await event.emitAsync();
      expect(result, 'first');
      expect(event.isCompleted, isTrue);
    });

    test('completeError 传递异常', () async {
      subscription = FxEmitter().on<TestAsyncEvent>((TestAsyncEvent event) {
        event.completeError(Exception('failed'));
      });

      final TestAsyncEvent event = TestAsyncEvent('err');
      expect(() => event.emitAsync(), throwsA(isA<Exception>()));
    });
  });
}
