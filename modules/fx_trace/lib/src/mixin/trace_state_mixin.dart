import 'package:flutter/material.dart';

import '../../fx_trace.dart';

mixin TraceStateMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    FxTrace().addTraceListener(onTrace);
  }

  @override
  void dispose() {
    FxTrace().removeTraceListener(onTrace);
    super.dispose();
  }

  void onTrace(Trace trace);
}
