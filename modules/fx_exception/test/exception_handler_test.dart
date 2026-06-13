import 'package:flutter_test/flutter_test.dart';
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
        RequestException(RequestErrorCode.convert, 'error'),
      );
      expect(received?.message, 'error');
    });

    test('多个监听器都收到通知', () {
      int count = 0;
      service.addTraceListener((Trace _) => count++);
      service.addTraceListener((Trace _) => count++);
      service.notifyTrace(
        RequestException(RequestErrorCode.emptyData, 'test'),
      );
      expect(count, 2);
    });

    test('removeTraceListener 后不再通知', () {
      int count = 0;
      void listener(Trace trace) => count++;

      service.addTraceListener(listener);
      service.notifyTrace(
        RequestException(RequestErrorCode.emptyData, 'first'),
      );
      service.removeTraceListener(listener);
      service.notifyTrace(
        RequestException(RequestErrorCode.emptyData, 'second'),
      );
      expect(count, 1);
    });

    test('dispose 清空所有监听器', () {
      int count = 0;
      service.addTraceListener((Trace _) => count++);
      service.dispose();
      service.notifyTrace(
        RequestException(RequestErrorCode.exception, 'after dispose'),
      );
      expect(count, 0);
    });
  });
}
