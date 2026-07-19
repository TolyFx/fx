import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fx_event/fx_event.dart';

import 'helper.dart';

void main() {
  group('FxEvent', () {
    test('emit() 通过 FxEmitter 发送', () async {
      String? received;
      final StreamSubscription<TestEvent> sub =
          FxEmitter().on<TestEvent>((TestEvent e) => received = e.name);

      const TestEvent('direct').emit();
      await Future<void>.delayed(Duration.zero);
      expect(received, 'direct');

      sub.cancel();
    });
  });
}
