```dart
import 'package:flutter/material.dart';
import 'package:fx_event/fx_event.dart';

// --- FxEmitterMixin: 监听所有事件 ---

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with FxEmitterMixin<HomePage> {
  @override
  void onEvent(FxEvent event) {
    if (event is RefreshListEvent) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) => const Placeholder();
}

// --- FxSingleEventMixin: 只监听特定类型 ---

class PriceUpdateEvent extends FxEvent {
  final double price;
  const PriceUpdateEvent(this.price);
}

class PricePage extends StatefulWidget {
  const PricePage({super.key});

  @override
  State<PricePage> createState() => _PricePageState();
}

class _PricePageState extends State<PricePage>
    with FxSingleEventMixin<PricePage, PriceUpdateEvent> {
  double _price = 0;

  @override
  void onEvent(PriceUpdateEvent event) {
    setState(() => _price = event.price);
  }

  @override
  Widget build(BuildContext context) => Text('$_price');
}
```
