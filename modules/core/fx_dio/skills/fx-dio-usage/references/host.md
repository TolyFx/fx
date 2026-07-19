```dart
import 'package:fx_dio/fx_dio.dart';

/// 自定义环境枚举
enum AppEnv { dev, staging, prod }

/// Host 定义模板
class ArticleHost extends RequestHost<AppEnv> {
  const ArticleHost();

  @override
  AppEnv get env => AppEnv.dev;

  @override
  Map<AppEnv, String> get value => {
    AppEnv.dev: '127.0.0.1',
    AppEnv.staging: 'staging.example.com',
    AppEnv.prod: 'api.example.com',
  };

  @override
  HostConfig get config => const HostConfig(
    scheme: 'https',
    port: 3000,
    apiNest: '/api/v1',
  );
}
```
