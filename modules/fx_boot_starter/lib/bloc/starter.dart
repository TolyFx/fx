import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

import '../fx_boot_starter.dart';

mixin FxStarter<T> implements AppStartAction<T> {
  Widget get app;

  AppStartRepository<T> get repository;

  void run([List<String>? args]) {
    runZonedGuarded(_runApp, onGlobalError);
  }

  void _runApp() {
    WidgetsFlutterBinding.ensureInitialized();
    // 设置 Flutter 错误处理
    FlutterError.onError = (details) {
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
        child: app,
        minStartDurationMs: 600,
      ),
    );
  }

  void onGlobalError(Object error, StackTrace stack);
}
