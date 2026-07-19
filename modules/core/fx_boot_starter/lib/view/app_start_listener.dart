import 'dart:async';

import 'package:flutter/material.dart';

import '../bloc/bloc.dart';
import '../bloc/state.dart';
import '../data/action/app_start_action.dart';
import 'app_start_scope.dart';

/// 监听启动状态变化，触发 [AppStartAction] 的对应回调。
///
/// 放在 Widget tree 中，自动响应 [AppStartBloc] 的状态流：
///
/// ```dart
/// AppStartListener<AppConfig>(
///   child: SplashPage(),
/// )
/// ```
class AppStartListener<S> extends StatefulWidget {
  final Widget child;

  const AppStartListener({
    super.key,
    required this.child,
  });

  @override
  State<AppStartListener<S>> createState() => _AppStartListenerState<S>();
}

class _AppStartListenerState<S> extends State<AppStartListener<S>> {
  StreamSubscription<AppStatus>? _subscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscription?.cancel();
    final AppStartBloc<S> bloc = AppStartScope.of<S>(context);
    _subscription = bloc.stream.listen(_onState);
  }

  void _onState(AppStatus status) {
    if (!mounted) return;
    final AppStartAction<S> action = AppStartScope.of<S>(context).startAction;
    if (status is AppLoadDone<S>) {
      action.onLoaded(context, status.cost, status.data);
    } else if (status is AppStartSuccess<S>) {
      action.onStartSuccess(context, status.data);
    } else if (status is AppStartFailed) {
      action.onStartError(context, status.error, status.trace);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
