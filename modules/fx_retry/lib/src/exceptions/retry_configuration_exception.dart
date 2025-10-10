/// 重试配置异常
class RetryConfigurationException implements Exception {
  const RetryConfigurationException(this.message);
  
  final String message;

  @override
  String toString() => 'RetryConfigurationException: $message';
}