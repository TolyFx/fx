import 'dart:async';

import 'fx_event.dart';

class FxEmitter {
  FxEmitter._();

  static FxEmitter? _instance;

  factory FxEmitter() {
    _instance ??= FxEmitter._();
    return _instance!;
  }

  final StreamController<FxEvent> _controller = StreamController.broadcast();

  Stream<FxEvent> get stream => _controller.stream;

  void emit(FxEvent action) {
    _controller.add(action);
  }
}
