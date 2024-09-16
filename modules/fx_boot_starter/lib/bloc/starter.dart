import 'dart:async';

import 'package:flutter/material.dart';

import '../fx_boot_starter.dart';

mixin FxStarter<T> implements AppStartAction<T>{
  Widget get app;

  AppStartRepository<T> get repository;

  void run(List<String> args) {
    runZonedGuarded(_runApp, onGlobalError);
  }

  void _runApp(){
    runApp(
      AppStartScope<T>(
        repository: repository,
        appStartAction: this,
        child: app,
      ),
    );
  }

  void onGlobalError(Object error, StackTrace stack);
}