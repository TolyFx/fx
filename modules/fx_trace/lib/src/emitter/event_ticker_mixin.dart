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
