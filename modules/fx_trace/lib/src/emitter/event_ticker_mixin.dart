import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'fx_emitter.dart';
import 'fx_event.dart';

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

/// 只监听 [E] 类型的事件
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
