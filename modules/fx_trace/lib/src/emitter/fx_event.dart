import 'dart:async';

import 'fx_emitter.dart';

class FxEvent {
  const FxEvent();

  void emit() => FxEmitter().emit(this);
}

/// 异步事件，发送方可以等待处理结果
class AsyncFxEvent<T> extends FxEvent {
  final Completer<T> _completer = Completer<T>();

  /// 等待事件处理完成并获取结果
  Future<T> get future => _completer.future;

  /// 处理方调用，完成事件并返回结果
  void complete(T result) {
    if (!_completer.isCompleted) {
      _completer.complete(result);
    }
  }

  /// 处理方调用，以错误完成事件
  void completeError(Object error, [StackTrace? stackTrace]) {
    if (!_completer.isCompleted) {
      _completer.completeError(error, stackTrace);
    }
  }

  bool get isCompleted => _completer.isCompleted;

  /// 发送并等待结果
  Future<T> emitAsync({Duration? timeout}) {
    FxEmitter().emit(this);
    if (timeout != null) {
      return future.timeout(timeout);
    }
    return future;
  }
}