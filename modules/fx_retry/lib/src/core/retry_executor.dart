import 'dart:async';
import '../policies/retry_policy.dart';
import '../conditions/retry_condition.dart';
import '../exceptions/retry_exhausted_exception.dart';
import '../exceptions/retry_timeout_exception.dart';
import '../exceptions/retry_configuration_exception.dart';
import '../types/retry_callback.dart';

/// 重试执行器
class RetryExecutor {
  static Future<T> execute<T>(
    Future<T> Function() operation, {
    required int maxAttempts,
    required RetryPolicy policy,
    required RetryCondition condition,
    Duration? timeout,
    RetryCallback? onRetry,
  }) async {
    if (maxAttempts <= 0) {
      throw const RetryConfigurationException('maxAttempts must be greater than 0');
    }

    Exception? lastException;
    final stopwatch = Stopwatch()..start();

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        if (timeout != null && stopwatch.elapsed >= timeout) {
          throw RetryTimeoutException(timeout: timeout);
        }

        final result = timeout != null
            ? await operation().timeout(timeout - stopwatch.elapsed)
            : await operation();

        return result;
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());

        if (attempt == maxAttempts) {
          break;
        }

        if (!condition.shouldRetry(lastException, attempt)) {
          break;
        }

        final delay = policy.calculateDelay(attempt);
        onRetry?.call(attempt, lastException, delay);

        if (delay.inMilliseconds > 0) {
          await Future.delayed(delay);
        }
      }
    }

    throw RetryExhaustedException(
      attempts: maxAttempts,
      lastException: lastException!,
    );
  }
}