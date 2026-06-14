/// 重试条件接口
abstract class RetryCondition {
  const RetryCondition();
  
  /// 判断是否应该重试
  bool shouldRetry(Exception exception, int attempt);
}

/// 总是重试的条件
class AlwaysRetryCondition implements RetryCondition {
  const AlwaysRetryCondition();
  
  @override
  bool shouldRetry(Exception exception, int attempt) => true;
}