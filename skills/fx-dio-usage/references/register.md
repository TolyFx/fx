```dart
import 'package:flutter/foundation.dart';
import 'package:fx_dio/fx_dio.dart';

void registerHttpClient() {
  // 注册 Host + 配置
  FxDio().register(
    const ArticleHost(),
    options: HostOptions(
      enableLog: kDebugMode,
      paginateParser: const DefaultPaginateParser(),
    ),
  );

  // 认证
  FxDio().auth<ArticleHost>(BearerTokenAuth(token: 'your_token'));

  // 运行时调整
  FxDio().setTimeout<ArticleHost>(connectTimeout: const Duration(seconds: 60));
  FxDio().setLog<ArticleHost>(false);
  FxDio().rebase<ArticleHost>(const NewArticleHost());
}
```
