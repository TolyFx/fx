import 'dart:async';

import 'fx_event.dart';

/// 对外提供指定类型事件的只读来源。
///
/// 事件域拥有者负责发送和释放，跨模块消费者只依赖此契约进行订阅。
abstract interface class FxEventSource<E extends FxEvent> {
  /// 当前来源公开的只读事件流。
  Stream<E> get events;
}
