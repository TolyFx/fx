import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fx_event/fx_event.dart';

import 'helper.dart';

void main() {
  group('FxEmitter', () {
    test('emit 和 on 正常工作', () async {
      String? received;
      final StreamSubscription<TestEvent> sub = FxEmitter().on<TestEvent>(
        (TestEvent e) => received = e.name,
      );

      const TestEvent('hello').emit();
      await Future<void>.delayed(Duration.zero);
      expect(received, 'hello');

      sub.cancel();
    });

    test('类型过滤，不同类型不触发', () {
      int count = 0;
      final StreamSubscription<TestEvent> sub = FxEmitter().on<TestEvent>(
        (_) => count++,
      );

      FxEmitter().emit(const FxEvent());
      expect(count, 0);

      sub.cancel();
    });

    test('多次调用返回同一实例', () {
      expect(identical(FxEmitter(), FxEmitter()), isTrue);
      expect(identical(FxEmitter(), FxEmitter.global), isTrue);
    });

    test('作用域事件流彼此隔离且支持类型化读取', () async {
      final FxEmitter first = FxEmitter.scoped();
      final FxEmitter second = FxEmitter.scoped();
      final List<String> firstEvents = [];
      final List<String> secondEvents = [];
      final StreamSubscription<TestEvent> firstSubscription = first
          .eventsOf<TestEvent>()
          .listen((TestEvent event) => firstEvents.add(event.name));
      final StreamSubscription<TestEvent> secondSubscription = second
          .eventsOf<TestEvent>()
          .listen((TestEvent event) => secondEvents.add(event.name));

      first.emit(const TestEvent('first'));
      second.emit(const TestEvent('second'));
      await Future<void>.delayed(Duration.zero);

      expect(firstEvents, <String>['first']);
      expect(secondEvents, <String>['second']);
      expect(identical(first, second), isFalse);
      expect(identical(first, FxEmitter()), isFalse);

      await firstSubscription.cancel();
      await secondSubscription.cancel();
      await first.dispose();
      await second.dispose();
    });

    test('作用域事件流可重复释放且释放后拒绝发送', () async {
      final FxEmitter emitter = FxEmitter.scoped();

      await emitter.dispose();
      await emitter.dispose();

      expect(emitter.isDisposed, isTrue);
      expect(
        () => emitter.emit(const TestEvent('late')),
        throwsA(isA<StateError>()),
      );
      await expectLater(FxEmitter().dispose(), throwsA(isA<StateError>()));
      expect(FxEmitter().isDisposed, isFalse);
    });

    test('cancel 后不再收到事件', () async {
      int count = 0;
      final StreamSubscription<TestEvent> sub = FxEmitter().on<TestEvent>(
        (_) => count++,
      );

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
