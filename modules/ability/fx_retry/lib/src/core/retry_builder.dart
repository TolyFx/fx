import '../policies/retry_policy.dart';
import '../policies/fixed_delay_policy.dart';
import '../policies/exponential_backoff_policy.dart';
import '../policies/linear_backoff_policy.dart';
import '../conditions/retry_condition.dart';
import '../conditions/exception_condition.dart';
import '../conditions/http_status_condition.dart';
import '../types/retry_callback.dart';
import 'retry_executor.dart';

/// 重试构建器
class RetryBuilder<T> {
  int _maxAttempts = 3;
  RetryPolicy _policy = const FixedDelayPolicy(delay: Duration(seconds: 1));
  RetryCondition _condition = const AlwaysRetryCondition();
  Duration? _timeout;
  RetryCallback? _onRetry;

  /// 设置最大重试次数
  RetryBuilder<T> maxAttempts(int attempts) {
    _maxAttempts = attempts;
    return this;
  }

  /// 设置固定延迟策略
  RetryBuilder<T> fixedDelay(Duration delay) {
    _policy = FixedDelayPolicy(delay: delay);
    return this;
  }

  /// 设置指数退避策略
  RetryBuilder<T> exponentialBackoff({
    Duration initialDelay = const Duration(seconds: 1),
    double multiplier = 2.0,
    Duration? maxDelay,
  }) {
    _policy = ExponentialBackoffPolicy(
      initialDelay: initialDelay,
      multiplier: multiplier,
      maxDelay: maxDelay,
    );
    return this;
  }

  /// 设置线性增长策略
  RetryBuilder<T> linearBackoff({
    Duration initialDelay = const Duration(seconds: 1),
    Duration increment = const Duration(seconds: 1),
    Duration? maxDelay,
  }) {
    _policy = LinearBackoffPolicy(
      initialDelay: initialDelay,
      increment: increment,
      maxDelay: maxDelay,
    );
    return this;
  }

  /// 设置重试异常类型
  RetryBuilder<T> retryOn<E extends Exception>() {
    _condition = ExceptionCondition<E>();
    return this;
  }

  /// 设置多种重试异常类型
  RetryBuilder<T> retryOnAny(List<Type> exceptionTypes) {
    // _condition = ExceptionCondition.anyOf(exceptionTypes);
    return this;
  }

  /// 设置HTTP状态码重试条件
  RetryBuilder<T> retryOnHttpStatus(List<int> statusCodes) {
    _condition = HttpStatusCondition(statusCodes);
    return this;
  }

  /// 设置超时时间
  RetryBuilder<T> timeout(Duration timeout) {
    _timeout = timeout;
    return this;
  }

  /// 设置重试回调
  RetryBuilder<T> onRetry(RetryCallback callback) {
    _onRetry = callback;
    return this;
  }

  /// 执行操作
  Future<T> execute(Future<T> Function() operation) {
    return RetryExecutor.execute(
      operation,
      maxAttempts: _maxAttempts,
      policy: _policy,
      condition: _condition,
      timeout: _timeout,
      onRetry: _onRetry,
    );
  }
}