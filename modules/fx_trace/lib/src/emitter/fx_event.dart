import 'fx_emitter.dart';

class FxEvent {
  const FxEvent();

  void emit() => FxEmitter().emit(this);
}
