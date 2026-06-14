import 'package:flutter_test/flutter_test.dart';
import 'package:fx_retry/fx_retry.dart';

void main() {
  group('FxRetry', () {
    test('should succeed on first attempt', () async {
      var callCount = 0;
      
      final result = await FxRetry.execute(
        () async {
          callCount++;
          return 'success';
        },
        maxAttempts: 3,
      );
      
      expect(result, equals('success'));
      expect(callCount, equals(1));
    });

    test('should retry on exception', () async {
      var callCount = 0;
      
      final result = await FxRetry.execute(
        () async {
          callCount++;
          if (callCount < 3) {
            throw Exception('temporary error');
          }
          return 'success';
        },
        maxAttempts: 3,
      );
      
      expect(result, equals('success'));
      expect(callCount, equals(3));
    });

    test('should throw RetryExhaustedException when max attempts reached', () async {
      var callCount = 0;
      
      expect(
        () => FxRetry.execute(
          () async {
            callCount++;
            throw Exception('persistent error');
          },
          maxAttempts: 3,
        ),
        throwsA(isA<RetryExhaustedException>()),
      );
      
      expect(callCount, equals(3));
    });

    test('should use exponential backoff policy', () async {
      final delays = <Duration>[];
      
      try {
        await FxRetry.builder<String>()
          .maxAttempts(3)
          .exponentialBackoff(initialDelay: Duration(milliseconds: 100))
          .onRetry((attempt, error, delay) {
            delays.add(delay);
          })
          .execute(() async => throw Exception('error'));
      } catch (e) {
        // Expected to fail
      }
      
      expect(delays.length, equals(2));
      expect(delays[0], equals(Duration(milliseconds: 100)));
      expect(delays[1], equals(Duration(milliseconds: 200)));
    });
  });
}