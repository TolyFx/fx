import 'dart:async';

import 'package:stream_transform/stream_transform.dart';

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

  StreamSubscription<E> on<E extends FxEvent>(void Function(E event)? handler) {
    return stream.whereType<E>().listen(handler);
  }

  void emit(FxEvent action) {
    _controller.add(action);
  }
}
