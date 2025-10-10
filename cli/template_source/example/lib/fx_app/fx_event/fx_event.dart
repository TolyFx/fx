import 'package:fx_trace/fx_trace.dart';

class NavToPage extends FxEvent {
  final int page;
  const NavToPage(this.page);
}
