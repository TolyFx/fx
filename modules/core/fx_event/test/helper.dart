import 'package:fx_event/fx_event.dart';

class TestEvent extends FxEvent {
  final String name;
  const TestEvent(this.name);
}

class TestAsyncEvent extends AsyncFxEvent<String> {
  final String input;
  TestAsyncEvent(this.input);
}
