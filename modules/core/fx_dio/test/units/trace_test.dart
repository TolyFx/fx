import 'package:flutter_test/flutter_test.dart';
import 'package:fx_dio/fx_dio.dart';

void main() {
  group('TraceMixin', () {
    test('监听器收到通知', () {
      Trace? received;
      FxDio().addTraceListener((Trace trace) => received = trace);

      FxDio().notifyTrace(
        RequestException(RequestErrorCode.convert, 'test error'),
      );

      expect(received?.message, 'test error');
    });

    test('移除监听器后不再收到', () {
      int count = 0;
      void listener(Trace trace) => count++;

      FxDio().addTraceListener(listener);
      FxDio().notifyTrace(
        RequestException(RequestErrorCode.emptyData, 'first'),
      );
      FxDio().removeTraceListener(listener);
      FxDio().notifyTrace(
        RequestException(RequestErrorCode.emptyData, 'second'),
      );
      expect(count, 1);
    });
  });
}
