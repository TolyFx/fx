import 'package:dio/dio.dart';
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

  group('请求成功', () {
    test('GET 请求 - 正常解析数据', () async {
      dioAdapter.onGet(
        '/users',
        (server) => server.reply(200, {
          'id': 1,
          'name': 'Toly',
        }),
      );

      final ApiRet<Map<String, dynamic>> result = await host.get(
        '/users',
        convertor: (dynamic data) => data as Map<String, dynamic>,
      );

      expect(result.success, isTrue);
      expect(result.data['name'], 'Toly');
    });

    test('POST 请求 - 发送 body 并解析', () async {
      dioAdapter.onPost(
        '/login',
        (server) => server.reply(200, {
          'token': 'abc123',
        }),
        data: {'username': 'toly', 'password': '123'},
      );

      final ApiRet<String> result = await host.post(
        '/login',
        data: {'username': 'toly', 'password': '123'},
        convertor: (dynamic data) =>
            (data as Map<String, dynamic>)['token'] as String,
      );

      expect(result.success, isTrue);
      expect(result.data, 'abc123');
    });

    test('响应含分页信息', () async {
      dioAdapter.onGet(
        '/posts',
        (server) => server.reply(200, {
          'data': [1, 2, 3],
          'total': 100,
        }),
      );

      final ApiRet<List<dynamic>> result = await host.get(
        '/posts',
        convertor: (dynamic data) =>
            (data as Map<String, dynamic>)['data'] as List<dynamic>,
      );

      expect(result.success, isTrue);
      expect(result.paginate?.total, 100);
    });
  });

  group('请求失败', () {
    test('响应 data 为 null - emptyData', () async {
      dioAdapter.onGet(
        '/empty',
        (server) => server.reply(200, null),
      );

      final ApiRet<String> result = await host.get(
        '/empty',
        convertor: (dynamic data) => data.toString(),
      );

      expect(result.failed, isTrue);
      expect(result.msg, 'request empty data');
    });

    test('convertor 抛异常 - convert error', () async {
      dioAdapter.onGet(
        '/bad',
        (server) => server.reply(200, {'value': 123}),
      );

      final ApiRet<String> result = await host.get(
        '/bad',
        convertor: (dynamic data) => throw const FormatException('bad format'),
      );

      expect(result.failed, isTrue);
      expect(result.msg, 'convert exception');
    });

    test('网络异常 - exception', () async {
      dioAdapter.onGet(
        '/timeout',
        (server) => server.throws(
          408,
          DioException(
            requestOptions: RequestOptions(path: '/timeout'),
            type: DioExceptionType.connectionTimeout,
          ),
        ),
      );

      final ApiRet<String> result = await host.get(
        '/timeout',
        convertor: (dynamic data) => data.toString(),
      );

      expect(result.failed, isTrue);
      expect(result.msg, 'request exception');
    });
  });

  group('异常追踪', () {
    test('失败时 TraceMixin 收到通知', () async {
      dioAdapter.onGet(
        '/fail',
        (server) => server.reply(200, null),
      );

      Trace? received;
      FxDio().addTraceListener((Trace trace) => received = trace);

      await host.get(
        '/fail',
        convertor: (dynamic data) => data.toString(),
      );

      expect(received, isNotNull);
      expect(received?.message, 'request empty data');
    });
  });
}
