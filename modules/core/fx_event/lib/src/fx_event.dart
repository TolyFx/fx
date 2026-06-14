import 'dart:async';

import 'fx_emitter.dart';

/// 事件基类，所有自定义事件都应继承此类。
///
/// 通过 [emit] 方法将事件发送到全局 [FxEmitter] 总线：
///
/// ```dart
/// class LoginEvent extends FxEvent {
///   final String userId;
///   const LoginEvent(this.userId);
/// }
///
/// // 发送
/// const LoginEvent('user_1').emit();
///
/// // 监听
/// FxEmitter().on<LoginEvent>((event) => print(event.userId));
/// ```
class FxEvent {
  const FxEvent();

  void emit() => FxEmitter().emit(this);
}

/// 异步事件，发送方可以等待处理方返回的结果。
///
/// 基于 [Completer] 实现请求-响应模式。每个实例是一次性的原子操作，
/// 发送后由处理方调用 [complete] 或 [completeError] 完成 future。
///
/// 适用场景：页面跳转等待返回值、弹窗确认、权限校验等。
///
/// ```dart
/// class PickColorEvent extends AsyncFxEvent<Color> {}
///
/// // 发送方
/// final color = await PickColorEvent().emitAsync();
///
/// // 处理方
/// FxEmitter().on<PickColorEvent>((event) {
///   final result = await showColorPicker();
///   event.complete(result);
/// });
/// ```
///
/// 注意事项：
/// - 调用 [emitAsync] 前需确保对应 handler 已注册，否则 future 永远不会完成。
/// - 可通过 [timeout] 参数设置超时保护，超时将抛出 [TimeoutException]。
/// - 多个 handler 同时 complete 时，仅第一次生效（first-wins）。
class AsyncFxEvent<T> extends FxEvent {
  final Completer<T> _completer = Completer<T>();

  Future<T> get future => _completer.future;

  void complete(T result) {
    if (!_completer.isCompleted) {
      _completer.complete(result);
    }
  }

  void completeError(Object error, [StackTrace? stackTrace]) {
    if (!_completer.isCompleted) {
      _completer.completeError(error, stackTrace);
    }
  }

  bool get isCompleted => _completer.isCompleted;

  Future<T> emitAsync({Duration? timeout}) {
    FxEmitter().emit(this);
    if (timeout != null) {
      return future.timeout(timeout);
    }
    return future;
  }
}
