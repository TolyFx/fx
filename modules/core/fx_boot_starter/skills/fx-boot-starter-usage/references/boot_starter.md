```dart
import 'package:flutter/material.dart';
import 'package:fx_boot_starter/fx_boot_starter.dart';

// ==================== 1. 配置类 ====================

class AppConfig {
  final String token;
  final bool isFirstLaunch;
  const AppConfig({this.token = '', this.isFirstLaunch = false});
}

// ==================== 2. Repository ====================

class MyStartRepository extends AppStartRepository<AppConfig> {
  const MyStartRepository();

  @override
  Future<AppConfig> initApp() async {
    // 初始化存储
    await SpStorage.instance.init();

    // 无依赖任务并行
    final List<dynamic> results = await Future.wait([
      DatabaseHelper.init(),
      fetchRemoteConfig(),
    ]);

    return AppConfig(
      token: results[1] as String,
      isFirstLaunch: await checkFirstLaunch(),
    );
  }
}

// ==================== 3. Application ====================

class MyApplication with FxStarter<AppConfig> {
  @override
  Widget get app => const MyApp();

  @override
  AppStartRepository<AppConfig> get repository => const MyStartRepository();

  @override
  void onLoaded(BuildContext context, int cost, AppConfig state) {
    debugPrint('启动耗时: $cost ms');
    // 可做预加载（图片、字体等）
  }

  @override
  void onStartSuccess(BuildContext context, AppConfig state) {
    // 跳转主页
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  void onStartError(BuildContext context, Object error, StackTrace trace) {
    // 跳转错误页
    Navigator.of(context).pushReplacementNamed('/error');
  }

  @override
  void onGlobalError(Object error, StackTrace stack) {
    // 上报未捕获异常
    CrashReporter.report(error, stack);
  }
}

// ==================== 4. main ====================

void main() {
  MyApplication().run();
}

// ==================== 5. UI 层 ====================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AppStartListener<AppConfig>(
        child: const SplashPage(),
      ),
    );
  }
}

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
```
