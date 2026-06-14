# 实现指南

## 项目结构

```
lib/
├── fx_retry.dart                 # 主入口文件
├── src/
│   ├── core/
│   │   ├── retry_executor.dart   # 核心执行器
│   │   ├── retry_builder.dart    # 构建器模式
│   │   └── retry_config.dart     # 配置类
│   ├── policies/
│   │   ├── retry_policy.dart     # 策略接口
│   │   ├── fixed_delay_policy.dart
│   │   ├── exponential_backoff_policy.dart
│   │   └── linear_backoff_policy.dart
│   ├── conditions/
│   │   ├── retry_condition.dart  # 条件接口
│   │   ├── exception_condition.dart
│   │   └── http_status_condition.dart
│   ├── exceptions/
│   │   ├── retry_exhausted_exception.dart
│   │   ├── retry_timeout_exception.dart
│   │   └── retry_configuration_exception.dart
│   └── types/
│       └── retry_callback.dart   # 回调类型定义
```

## 核心实现

### 1. 主入口类 (fx_retry.dart)

```dart
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
```

### 2. 核心执行器 (retry_executor.dart)

```dart
import 'dart:async';

class RetryExecutor {
  static Future<T> execute<T>(
    Future<T> Function() operation, {
    required int maxAttempts,
    required RetryPolicy policy,
    required RetryCondition condition,
    Duration? timeout,
    RetryCallback? onRetry,
  }) async {
    if (maxAttempts <= 0) {
      throw RetryConfigurationException('maxAttempts must be greater than 0');
    }

    Exception? lastException;
    final stopwatch = Stopwatch()..start();

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        // 检查总体超时
        if (timeout != null && stopwatch.elapsed >= timeout) {
          throw RetryTimeoutException(timeout: timeout);
        }

        // 执行操作
        final result = timeout != null
            ? await operation().timeout(timeout - stopwatch.elapsed)
            : await operation();

        return result;
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());

        // 最后一次尝试，直接抛出异常
        if (attempt == maxAttempts) {
          break;
        }

        // 检查是否应该重试
        if (!condition.shouldRetry(lastException, attempt)) {
          break;
        }

        // 计算延迟时间
        final delay = policy.calculateDelay(attempt);

        // 调用重试回调
        onRetry?.call(attempt, lastException, delay);

        // 等待延迟时间
        if (delay.inMilliseconds > 0) {
          await Future.delayed(delay);
        }
      }
    }

    // 抛出重试耗尽异常
    throw RetryExhaustedException(
      attempts: maxAttempts,
      lastException: lastException!,
    );
  }
}
```

### 3. 构建器模式 (retry_builder.dart)

```dart
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
    _condition = ExceptionCondition.anyOf(exceptionTypes);
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
```

### 4. 重试策略实现

#### 策略接口 (retry_policy.dart)

```dart
abstract class RetryPolicy {
  const RetryPolicy();
  
  /// 计算第 [attempt] 次重试的延迟时间
  Duration calculateDelay(int attempt);
}
```

#### 固定延迟策略 (fixed_delay_policy.dart)

```dart
class FixedDelayPolicy implements RetryPolicy {
  const FixedDelayPolicy({
    required this.delay,
  });

  final Duration delay;

  @override
  Duration calculateDelay(int attempt) => delay;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FixedDelayPolicy &&
          runtimeType == other.runtimeType &&
          delay == other.delay;

  @override
  int get hashCode => delay.hashCode;

  @override
  String toString() => 'FixedDelayPolicy(delay: $delay)';
}
```

#### 指数退避策略 (exponential_backoff_policy.dart)

```dart
import 'dart:math' as math;

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExponentialBackoffPolicy &&
          runtimeType == other.runtimeType &&
          initialDelay == other.initialDelay &&
          multiplier == other.multiplier &&
          maxDelay == other.maxDelay;

  @override
  int get hashCode => Object.hash(initialDelay, multiplier, maxDelay);

  @override
  String toString() => 
      'ExponentialBackoffPolicy(initialDelay: $initialDelay, '
      'multiplier: $multiplier, maxDelay: $maxDelay)';
}
```

### 5. 重试条件实现

#### 条件接口 (retry_condition.dart)

```dart
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
```

#### 异常条件 (exception_condition.dart)

```dart
class ExceptionCondition<T extends Exception> implements RetryCondition {
  const ExceptionCondition();

  factory ExceptionCondition.anyOf(List<Type> exceptionTypes) {
    return AnyExceptionCondition(exceptionTypes);
  }

  @override
  bool shouldRetry(Exception exception, int attempt) {
    return exception is T;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExceptionCondition<T> && runtimeType == other.runtimeType;

  @override
  int get hashCode => T.hashCode;

  @override
  String toString() => 'ExceptionCondition<$T>()';
}

class AnyExceptionCondition implements RetryCondition {
  const AnyExceptionCondition(this.exceptionTypes);

  final List<Type> exceptionTypes;

  @override
  bool shouldRetry(Exception exception, int attempt) {
    return exceptionTypes.any((type) => exception.runtimeType == type);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnyExceptionCondition &&
          runtimeType == other.runtimeType &&
          _listEquals(exceptionTypes, other.exceptionTypes);

  @override
  int get hashCode => Object.hashAll(exceptionTypes);

  @override
  String toString() => 'AnyExceptionCondition($exceptionTypes)';

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}
```

### 6. 异常类实现

#### 重试耗尽异常 (retry_exhausted_exception.dart)

```dart
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RetryExhaustedException &&
          runtimeType == other.runtimeType &&
          attempts == other.attempts &&
          lastException == other.lastException;

  @override
  int get hashCode => Object.hash(attempts, lastException);
}
```

## 测试实现

### 单元测试结构

```
test/
├── fx_retry_test.dart           # 主要功能测试
├── policies/
│   ├── fixed_delay_policy_test.dart
│   ├── exponential_backoff_policy_test.dart
│   └── linear_backoff_policy_test.dart
├── conditions/
│   ├── exception_condition_test.dart
│   └── http_status_condition_test.dart
├── core/
│   ├── retry_executor_test.dart
│   └── retry_builder_test.dart
└── integration/
    └── real_world_scenarios_test.dart
```

### 核心测试示例

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fx_retry/fx_retry.dart';

void main() {
  group('FxRetry', () {
    test('should succeed on first attempt', () async {
      var callCount = 0;
      
      final result = await FxRetry.execute(
        () async {
          callCount++;
          return 'success';
        },
        maxAttempts: 3,
      );
      
      expect(result, equals('success'));
      expect(callCount, equals(1));
    });

    test('should retry on exception', () async {
      var callCount = 0;
      
      final result = await FxRetry.execute(
        () async {
          callCount++;
          if (callCount < 3) {
            throw Exception('temporary error');
          }
          return 'success';
        },
        maxAttempts: 3,
      );
      
      expect(result, equals('success'));
      expect(callCount, equals(3));
    });

    test('should throw RetryExhaustedException when max attempts reached', () async {
      var callCount = 0;
      
      expect(
        () => FxRetry.execute(
          () async {
            callCount++;
            throw Exception('persistent error');
          },
          maxAttempts: 3,
        ),
        throwsA(isA<RetryExhaustedException>()),
      );
      
      expect(callCount, equals(3));
    });
  });
}
```

## 性能优化

### 1. 内存优化
- 使用 const 构造函数减少对象创建
- 避免不必要的字符串拼接
- 及时释放资源

### 2. 异步优化
- 使用 Future.timeout 避免无限等待
- 合理使用 Completer 控制异步流程
- 避免阻塞主线程

### 3. 错误处理优化
- 精确的异常类型匹配
- 避免捕获过于宽泛的异常
- 提供详细的错误信息

## 发布准备

### 1. 版本管理
- 遵循语义化版本控制
- 维护详细的 CHANGELOG
- 标记重要的 API 变更

### 2. 文档完善
- API 文档自动生成
- 示例代码验证
- 最佳实践指南

### 3. 质量保证
- 100% 测试覆盖率
- 静态代码分析
- 性能基准测试