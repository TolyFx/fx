import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'fx_emitter.dart';
import 'fx_event.dart';

/// 监听所有事件的 State mixin，自动管理订阅生命周期。
///
/// 在 [initState] 时订阅 [FxEmitter] 的全量事件流，
/// 在 [dispose] 时自动取消订阅，无需手动管理。
///
/// ```dart
/// class _MyPageState extends State<MyPage> with FxEmitterMixin {
///   @override
///   void onEvent(FxEvent event) {
///     if (event is RefreshEvent) setState(() {});
///   }
/// }
/// ```
mixin FxEmitterMixin<T extends StatefulWidget> on State<T> {
  StreamSubscription<FxEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = FxEmitter().stream.listen(onEvent);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void onEvent(FxEvent event);
}

/// 只监听指定类型 [E] 事件的 State mixin，自动管理订阅生命周期。
///
/// 相比 [FxEmitterMixin]，只接收特定类型的事件，更精确。
///
/// ```dart
/// class _DetailState extends State<Detail>
///     with FxSingleEventMixin<Detail, PriceUpdateEvent> {
///   @override
///   void onEvent(PriceUpdateEvent event) {
///     setState(() => price = event.price);
///   }
/// }
/// ```
mixin FxSingleEventMixin<T extends StatefulWidget, E extends FxEvent>
    on State<T> {
  StreamSubscription<FxEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = FxEmitter().on<E>(onEvent);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void onEvent(E event);
}
