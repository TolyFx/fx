import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data/action/app_start_action.dart';
import '../data/repository.dart';
import '../view/app_start_scope.dart';

/// 应用启动入口 mixin。
///
/// 组合 [AppStartAction] 和启动配置，通过 [run] 一行启动：
///
/// ```dart
/// class MyApp with FxStarter<AppConfig> {
///   @override
///   Widget get app => MyAppWidget();
///
///   @override
///   AppStartRepository<AppConfig> get repository => MyRepository();
///
///   // 实现 AppStartAction 的三个回调...
/// }
///
/// void main() => MyApp().run();
/// ```
mixin FxStarter<T> implements AppStartAction<T> {
  Widget get app;

  AppStartRepository<T> get repository;

  int get minStartDurationMs => 600;

  void run([List<String>? args]) {
    runZonedGuarded(_runApp, onGlobalError);
  }

  void _runApp() {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      if (kDebugMode) {
        debugPrint('FlutterError: ${details.exception}');
        debugPrint('Stack: ${details.stack}');
      }
    };

    runApp(
      AppStartScope<T>(
        repository: repository,
        appStartAction: this,
        minStartDurationMs: minStartDurationMs,
        child: app,
      ),
    );
  }

  void onGlobalError(Object error, StackTrace stack);
}
