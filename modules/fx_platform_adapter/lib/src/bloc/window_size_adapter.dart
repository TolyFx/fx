
import 'package:flutter/material.dart';

import 'package:window_manager/window_manager.dart';

import '../data/global.dart' as g;


class WindowSizeAdapter {
  static Future<void> setSize({
    Size size = const Size(920, 680),
    Size minimumSize = const Size(640, 320),
  }) async {
    if (g.kAppEnv.isDesktop) {
      //仅对桌面端进行尺寸设置
      await windowManager.ensureInitialized();
      WindowOptions windowOptions = WindowOptions(
        size: size,
        minimumSize: minimumSize,
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.hidden,
      );
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.setTitleBarStyle(TitleBarStyle.hidden,
            windowButtonVisibility: false);
        await windowManager.show();
        await windowManager.focus();
      });
    }
  }
}
