import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc.dart';

extension StartContext on BuildContext {
  void startApp<S>() => read<AppStartBloc<S>>().startApp();
}
