import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx/src/model/app_config.dart';
import 'package:fx_boot_starter/fx_boot_starter.dart';
import 'package:go_router/go_router.dart';

import '../fx_gui.dart';
import 'start_repository.dart';

export 'view/splash/Flutter_unit_splash.dart';
export 'view/error/app_start_error.dart';

class FxApplication with FxStarter<AppConfig> {

  const FxApplication();

  @override
  Widget get app =>  FxGui();

  @override
  AppStartRepository<AppConfig> get repository => const FlutterUnitStartRepo();

  @override
  void onLoaded(BuildContext context, int cost, AppConfig state) {
    debugPrint("App启动耗时:$cost ms");
  }

  @override
  void onStartSuccess(BuildContext context, AppConfig state) {
    // context.go('/widget');
  }

  @override
  void onStartError(BuildContext context, Object error, StackTrace trace) {
    // context.go('/start_error',extra: error);
  }


  @override
  void onGlobalError(Object error, StackTrace stack) {
    print(error);
  }
}

