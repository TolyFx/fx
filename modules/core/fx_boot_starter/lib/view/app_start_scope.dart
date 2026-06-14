import 'package:flutter/material.dart';

import '../bloc/bloc.dart';
import '../data/action/app_start_action.dart';
import '../data/repository.dart';

/// 启动作用域，提供 [AppStartBloc] 给子树。
///
/// 在 Widget tree 顶层包裹，内部自动创建 bloc 并触发 [startApp]。
///
/// ```dart
/// AppStartScope<AppConfig>(
///   repository: MyRepository(),
///   appStartAction: MyAction(),
///   minStartDurationMs: 800,
///   child: MyApp(),
/// )
/// ```
class AppStartScope<S> extends StatefulWidget {
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

  /// 从 Widget tree 中获取 [AppStartBloc] 实例
  static AppStartBloc<S> of<S>(BuildContext context) {
    final _AppStartInherited<S>? inherited =
        context.dependOnInheritedWidgetOfExactType<_AppStartInherited<S>>();
    assert(inherited != null, 'AppStartScope<$S> not found in widget tree.');
    return inherited!.bloc;
  }

  @override
  State<AppStartScope<S>> createState() => _AppStartScopeState<S>();
}

class _AppStartScopeState<S> extends State<AppStartScope<S>> {
  late final AppStartBloc<S> _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = AppStartBloc<S>(
      repository: widget.repository,
      startAction: widget.appStartAction,
      minStartDurationMs: widget.minStartDurationMs,
    )..startApp();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AppStartInherited<S>(
      bloc: _bloc,
      child: widget.child,
    );
  }
}

class _AppStartInherited<S> extends InheritedWidget {
  final AppStartBloc<S> bloc;

  const _AppStartInherited({
    required this.bloc,
    required super.child,
  });

  @override
  bool updateShouldNotify(_AppStartInherited<S> oldWidget) => false;
}
