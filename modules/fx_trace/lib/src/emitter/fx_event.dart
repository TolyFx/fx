import 'dart:async';

import 'fx_emitter.dart';

class FxEvent {
  const FxEvent();

  void emit() => FxEmitter().emit(this);
}

class AsyncFxEvent<T> extends FxEvent{
  final Completer<T> task;
  AsyncFxEvent(this.task);
}