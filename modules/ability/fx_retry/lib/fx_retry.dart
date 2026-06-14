library fx_retry;

export 'src/core/retry_executor.dart';
export 'src/core/retry_builder.dart';
export 'src/policies/retry_policy.dart';
export 'src/policies/fixed_delay_policy.dart';
export 'src/policies/exponential_backoff_policy.dart';
export 'src/policies/linear_backoff_policy.dart';
export 'src/conditions/retry_condition.dart';
export 'src/conditions/exception_condition.dart';
export 'src/conditions/http_status_condition.dart';
export 'src/exceptions/retry_exhausted_exception.dart';
export 'src/exceptions/retry_timeout_exception.dart';
export 'src/exceptions/retry_configuration_exception.dart';
export 'src/types/retry_callback.dart';

import 'fx_retry.dart';
import 'src/core/retry_executor.dart';
import 'src/core/retry_builder.dart';
import 'src/policies/fixed_delay_policy.dart';
import 'src/conditions/retry_condition.dart';
import 'src/types/retry_callback.dart';

/// Flutter 重试机制的主入口类
class FxRetry {
  /// 执行带重试的异步操作
  static Future<T> execute<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    RetryPolicy? policy,
    RetryCondition? condition,
    Duration? timeout,
    RetryCallback? onRetry,
  }) {
    return RetryExecutor.execute(
      operation,
      maxAttempts: maxAttempts,
      policy: policy ?? const FixedDelayPolicy(delay: Duration(seconds: 1)),
      condition: condition ?? const AlwaysRetryCondition(),
      timeout: timeout,
      onRetry: onRetry,
    );
  }

  /// 创建重试构建器
  static RetryBuilder<T> builder<T>() => RetryBuilder<T>();
}
