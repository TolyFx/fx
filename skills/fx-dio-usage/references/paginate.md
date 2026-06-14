```dart
import 'package:fx_dio/fx_dio.dart';

/// 自定义分页解析器
class MyPaginateParser extends PaginateParser {
  const MyPaginateParser();

  @override
  Paginate? parse(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    final dynamic count = data['count'];
    if (count == null) return null;
    return Paginate(total: count is int ? count : int.tryParse('$count') ?? 0);
  }
}

/// 注册时按 Host 绑定
void example() {
  FxDio().register(
    const HostA(),
    options: const HostOptions(paginateParser: MyPaginateParser()),
  );
  FxDio().register(const HostB()); // 用默认 DefaultPaginateParser
}
```
