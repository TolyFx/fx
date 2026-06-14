/// 重试次数耗尽异常
class RetryExhaustedException implements Exception {
  const RetryExhaustedException({
    required this.attempts,
    required this.lastException,
  });

  final int attempts;
  final Exception lastException;

  @override
  String toString() =>
      'RetryExhaustedException: Failed after $attempts attempts. '
      'Last exception: $lastException';
}