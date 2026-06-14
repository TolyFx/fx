import 'dart:async';

import 'ext/where_type_stream.dart';
import 'fx_event.dart';

/// 全局事件总线，基于 broadcast [StreamController] 实现。
///
/// 单例模式，整个应用共享一个实例。通过 [emit] 发送事件，
/// 通过 [on] 按类型监听特定事件，通过 [stream] 监听所有事件。
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
  FxEmitter._();

  static FxEmitter? _instance;

  factory FxEmitter() {
    _instance ??= FxEmitter._();
    return _instance!;
  }

  final StreamController<FxEvent> _controller = StreamController<FxEvent>.broadcast();

  /// 所有事件的原始流
  Stream<FxEvent> get stream => _controller.stream;

  /// 监听指定类型 [E] 的事件，内部使用单层 controller 做类型过滤，零中间 stream 开销。
  StreamSubscription<E> on<E extends FxEvent>(void Function(E event)? handler) {
    return stream.whereType<E>().listen(handler);
  }

  /// 发送事件到总线
  void emit(FxEvent action) {
    _controller.add(action);
  }
}
