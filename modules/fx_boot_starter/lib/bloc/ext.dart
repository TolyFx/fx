import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc.dart';

extension FixContext on BuildContext {
  void bloc<S>() => read<AppStartBloc<S>>();
}
