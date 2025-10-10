/// 重试超时异常
class RetryTimeoutException implements Exception {
  const RetryTimeoutException({
    required this.timeout,
  });
  
  final Duration timeout;

  @override
  String toString() => 'RetryTimeoutException: Operation timed out after $timeout';
}