import 'package:flutter/material.dart';
import 'package:fx_boot_starter/fx_boot_starter.dart';

/// 启动配置
class AppConfig {
  final String theme;
  const AppConfig({this.theme = 'light'});
}

/// 启动仓库
class MyRepository extends AppStartRepository<AppConfig> {
  const MyRepository();

  @override
  Future<AppConfig> initApp() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return const AppConfig(theme: 'dark');
  }
}

/// 应用入口
class MyApplication with FxStarter<AppConfig> {
  @override
  Widget get app => const MyApp();

  @override
  AppStartRepository<AppConfig> get repository => const MyRepository();

  @override
  void onLoaded(BuildContext context, int cost, AppConfig state) {
    debugPrint('启动耗时: $cost ms');
  }

  @override
  void onStartSuccess(BuildContext context, AppConfig state) {
    debugPrint('启动成功: theme=${state.theme}');
  }

  @override
  void onStartError(BuildContext context, Object error, StackTrace trace) {
    debugPrint('启动失败: $error');
  }

  @override
  void onGlobalError(Object error, StackTrace stack) {
    debugPrint('全局异常: $error');
  }
}

void main() {
  MyApplication().run();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AppStartListener<AppConfig>(
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
