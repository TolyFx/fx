```dart
import 'dart:convert';

import 'package:fx_dio/fx_dio.dart';

/// 解密示例
Future<void> example(RequestHost host) async {
  final ApiRet<Map<String, dynamic>> ret = await host.get(
    '/encrypted',
    convertor: (dynamic data) => data as Map<String, dynamic>,
    decryptConvertor: (String encrypted) =>
        utf8.decode(base64Decode(encrypted)),
  );
}

// 响应为 String → 整体解密后 jsonDecode
// 响应为 Map 且 data 字段为 String → 只解密 data 字段
```
