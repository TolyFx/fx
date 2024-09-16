import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fx_boot_starter/fx_boot_starter.dart';
import 'package:flutter/services.dart';
import 'package:fx_platform_adapter/fx_platform_adapter.dart';
import 'package:path/path.dart' as path;

import '../model/app_config.dart';

class FlutterUnitStartRepo implements AppStartRepository<AppConfig> {
  const FlutterUnitStartRepo();

  /// 初始化 app 的异步任务
  /// 返回本地持久化的 AppConfigState 对象
  @override
  Future<AppConfig> initApp() async {
    WidgetsFlutterBinding.ensureInitialized();
    WindowSizeAdapter.setSize();

    // 滚动性能优化 1.22.0
    // GestureBinding.instance.resamplingEnabled = true;
    // WindowSizeAdapter.setSize();
    // // throw 'Test Debug Start Error';
    // await SpStorage.instance.initSp();
    // if (!kAppEnv.isWeb) await initDb();
    // AppConfigPo po = await SpStorage.instance.appConfig.read();
    // List<ConnectivityResult> netConnect = await (Connectivity().checkConnectivity());
    // AppConfig state = AppConfig.fromPo(po);
    // if (netConnect.isNotEmpty) {
    //   state = state.copyWith(netConnect: netConnect.first);
    // }
    return AppConfig();
  }
}
