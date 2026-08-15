import 'dart:async';

import 'ext/where_type_stream.dart';
import 'fx_event.dart';

/// 指定类型事件的监听回调。
typedef FxEventHandler<E extends FxEvent> = void Function(E event);

/// 类型化事件发射器，基于 broadcast [StreamController] 实现。
///
/// 默认构造返回整个应用共享的 [global] 实例；[FxEmitter.scoped] 创建由
/// 调用方独占的事件域。通过 [emit] 发送事件，通过 [on] 按类型监听特定事件，
/// 通过 [stream] 监听当前事件域中的全部事件。
///
/// ```dart
/// // 发送事件
/// FxEmitter().emit(const LoginEvent('user_1'));
///
/// // 按类型监听
/// final sub = FxEmitter().on<LoginEvent>((event) => print(event.userId));
///
/// // 监听所有事件
/// FxEmitter().stream.listen((event) => print(event));
/// ```
class FxEmitter {
  /// 兼容原有调用方式的全局事件总线。
  static final FxEmitter global = FxEmitter._global();

  /// 当前事件域使用的广播控制器。
  final StreamController<FxEvent> _controller;

  /// 当前实例是否由调用方拥有并允许释放。
  final bool _isScoped;

  /// 保持 `FxEmitter()` 始终返回原有全局单例。
  factory FxEmitter() => global;

  FxEmitter._global()
      : _controller = StreamController<FxEvent>.broadcast(),
        _isScoped = false;

  /// 创建由调用方独占并负责释放的事件域。
  FxEmitter.scoped({bool sync = false})
      : _controller = StreamController<FxEvent>.broadcast(sync: sync),
        _isScoped = true;

  /// 当前事件域中的全部原始事件。
  Stream<FxEvent> get stream => _controller.stream;

  /// 当前事件域是否已经释放。
  bool get isDisposed => _controller.isClosed;

  /// 返回当前事件域中指定类型的只读事件流。
  Stream<E> eventsOf<E extends FxEvent>() => stream.whereType<E>();

  /// 监听当前事件域中的指定事件类型。
  StreamSubscription<E> on<E extends FxEvent>(FxEventHandler<E>? handler) {
    return eventsOf<E>().listen(handler);
  }

  /// 向当前事件域发送事件。
  void emit(FxEvent event) {
    if (_controller.isClosed) {
      throw StateError('FxEmitter 已释放，不能继续发送事件');
    }
    _controller.add(event);
  }

  /// 释放作用域事件流；全局事件总线不允许释放。
  Future<void> dispose() async {
    if (!_isScoped) {
      throw StateError('全局 FxEmitter 不允许释放');
    }
    if (_controller.isClosed) return;
    await _controller.close();
  }
}
