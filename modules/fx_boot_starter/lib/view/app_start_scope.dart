import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bloc.dart';
import '../data/action/app_start_action.dart';
import '../data/repository.dart';

class AppStartScope<S> extends StatelessWidget {
  final AppStartRepository<S> repository;
  final AppStartAction<S> appStartAction;
  final int minStartDurationMs;

  final Widget child;

  const AppStartScope({
    super.key,
    required this.repository,
    required this.appStartAction,
    required this.child,
    this.minStartDurationMs = 600,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      lazy: false,
      create: (BuildContext context) => AppStartBloc<S>(
        startAction: appStartAction,
        repository: repository,
        minStartDurationMs: minStartDurationMs,
      )..startApp(),
      child: child,
    );
  }
}
