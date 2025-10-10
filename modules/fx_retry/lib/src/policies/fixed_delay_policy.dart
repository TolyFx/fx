import 'retry_policy.dart';

/// 固定延迟策略
class FixedDelayPolicy implements RetryPolicy {
  const FixedDelayPolicy({
    required this.delay,
  });

  final Duration delay;

  @override
  Duration calculateDelay(int attempt) => delay;
}