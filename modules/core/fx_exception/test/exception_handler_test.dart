import 'package:test/test.dart';
import 'package:fx_exception/fx_exception.dart';

class TestService with TraceMixin {}

void main() {
  late TestService service;

  setUp(() {
    service = TestService();
  });

  group('TraceMixin', () {
    test('监听器收到通知', () {
      Trace? received;
      service.addTraceListener((Trace trace) => received = trace);
      service.notifyTrace(
        const RequestException(RequestErrorCode.convert, 'error'),
      );
      expect(received?.message, 'error');
    });

    test('多个监听器都收到通知', () {
      int count = 0;
      service.addTraceListener((Trace _) => count++);
      service.addTraceListener((Trace _) => count++);
      service.notifyTrace(
        const RequestException(RequestErrorCode.emptyData, 'test'),
      );
      expect(count, 2);
    });

    test('监听器异常不会阻断后续监听器', () {
      int count = 0;
      service.addTraceListener((Trace _) => throw StateError('listener'));
      service.addTraceListener((Trace _) => count++);

      service.notifyTrace(
        const RequestException(RequestErrorCode.emptyData, 'test'),
      );

      expect(count, 1);
    });

    test('removeTraceListener 后不再通知', () {
      int count = 0;
      void listener(Trace trace) => count++;

      service.addTraceListener(listener);
      service.notifyTrace(
        const RequestException(RequestErrorCode.emptyData, 'first'),
      );
      service.removeTraceListener(listener);
      service.notifyTrace(
        const RequestException(RequestErrorCode.emptyData, 'second'),
      );
      expect(count, 1);
    });

    test('dispose 清空所有监听器', () {
      int count = 0;
      service.addTraceListener((Trace _) => count++);
      service.dispose();
      service.notifyTrace(
        const RequestException(RequestErrorCode.exception, 'after dispose'),
      );
      expect(count, 0);
    });
  });
}
