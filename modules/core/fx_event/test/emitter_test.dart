import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fx_event/fx_event.dart';

import 'helper.dart';

void main() {
  group('FxEmitter', () {
    test('emit 和 on 正常工作', () async {
      String? received;
      final StreamSubscription<TestEvent> sub =
          FxEmitter().on<TestEvent>((TestEvent e) => received = e.name);

      const TestEvent('hello').emit();
      await Future<void>.delayed(Duration.zero);
      expect(received, 'hello');

      sub.cancel();
    });

    test('类型过滤，不同类型不触发', () {
      int count = 0;
      final StreamSubscription<TestEvent> sub =
          FxEmitter().on<TestEvent>((_) => count++);

      FxEmitter().emit(const FxEvent());
      expect(count, 0);

      sub.cancel();
    });

    test('多次调用返回同一实例', () {
      expect(identical(FxEmitter(), FxEmitter()), isTrue);
    });

    test('cancel 后不再收到事件', () async {
      int count = 0;
      final StreamSubscription<TestEvent> sub =
          FxEmitter().on<TestEvent>((_) => count++);

      const TestEvent('a').emit();
      await Future<void>.delayed(Duration.zero);
      expect(count, 1);

      sub.cancel();

      const TestEvent('b').emit();
      await Future<void>.delayed(Duration.zero);
      expect(count, 1);
    });
  });
}
