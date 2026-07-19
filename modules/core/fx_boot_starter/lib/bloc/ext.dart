import 'package:flutter/widgets.dart';

import '../view/app_start_scope.dart';

extension StartContext on BuildContext {
  void startApp<S>() => AppStartScope.of<S>(this).startApp();
}
