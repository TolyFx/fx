/// 重试策略接口
abstract class RetryPolicy {
  const RetryPolicy();
  
  /// 计算第 [attempt] 次重试的延迟时间
  Duration calculateDelay(int attempt);
}