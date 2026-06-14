import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fx_dio/fx_dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import 'helper.dart';

void main() {
  late DioAdapter dioAdapter;
  late MockHost host;

  setUp(() {
    host = MockHost();
    FxDio().unregister(host);
    FxDio().register(host, options: const HostOptions(enableLog: false));
    dioAdapter = DioAdapter(dio: FxDio()[host]);
  });

  group('解密', () {
    test('String 响应 + decryptConvertor', () async {
      final Map<String, dynamic> payload = {'name': 'Toly'};
      final String encrypted =
          base64Encode(utf8.encode(jsonEncode(payload)));

      dioAdapter.onGet(
        '/secret',
        (server) => server.reply(200, encrypted),
      );

      final ApiRet<Map<String, dynamic>> result = await host.get(
        '/secret',
        convertor: (dynamic data) => data as Map<String, dynamic>,
        decryptConvertor: (String data) => utf8.decode(base64Decode(data)),
      );

      expect(result.success, isTrue);
      expect(result.data['name'], 'Toly');
    });

    test('Map 响应 + decryptConvertor 解密 data 字段', () async {
      final Map<String, dynamic> inner = {'id': 42};
      final String encryptedInner =
          base64Encode(utf8.encode(jsonEncode(inner)));

      dioAdapter.onGet(
        '/partial',
        (server) => server.reply(200, {
          'code': 0,
          'data': encryptedInner,
        }),
      );

      final ApiRet<Map<String, dynamic>> result = await host.get(
        '/partial',
        convertor: (dynamic data) => data as Map<String, dynamic>,
        decryptConvertor: (String data) => utf8.decode(base64Decode(data)),
      );

      expect(result.success, isTrue);
      expect(result.data['data']['id'], 42);
    });
  });
}
