import 'retry_policy.dart';

/// 线性增长策略
class LinearBackoffPolicy implements RetryPolicy {
  const LinearBackoffPolicy({
    this.initialDelay = const Duration(seconds: 1),
    this.increment = const Duration(seconds: 1),
    this.maxDelay,
  });

  final Duration initialDelay;
  final Duration increment;
  final Duration? maxDelay;

  @override
  Duration calculateDelay(int attempt) {
    final delayMs = initialDelay.inMilliseconds + 
        (increment.inMilliseconds * (attempt - 1));
    
    var delay = Duration(milliseconds: delayMs);
    
    if (maxDelay != null && delay > maxDelay!) {
      delay = maxDelay!;
    }
    
    return delay;
  }
}