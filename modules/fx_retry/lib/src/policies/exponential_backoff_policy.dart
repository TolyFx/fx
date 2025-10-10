import 'dart:math' as math;
import 'retry_policy.dart';

/// 指数退避策略
class ExponentialBackoffPolicy implements RetryPolicy {
  const ExponentialBackoffPolicy({
    this.initialDelay = const Duration(seconds: 1),
    this.multiplier = 2.0,
    this.maxDelay,
  });

  final Duration initialDelay;
  final double multiplier;
  final Duration? maxDelay;

  @override
  Duration calculateDelay(int attempt) {
    final delayMs = initialDelay.inMilliseconds * 
        math.pow(multiplier, attempt - 1);
    
    var delay = Duration(milliseconds: delayMs.round());
    
    if (maxDelay != null && delay > maxDelay!) {
      delay = maxDelay!;
    }
    
    return delay;
  }
}