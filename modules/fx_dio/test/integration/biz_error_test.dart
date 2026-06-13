import 'package:flutter_test/flutter_test.dart';
import 'package:fx_dio/fx_dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import 'helper.dart';

/// 模拟后端统一响应格式：{ code: int, message: String, data: dynamic }
/// 当 code != 0 时视为业务异常

enum BizCode with Code {
  ok(0),
  tokenExpired(401),
  forbidden(403),
  notFound(10001),
  ;

  @override
  final int code;

  const BizCode(this.code);

  static BizCode fromInt(int value) {
    return BizCode.values.firstWhere(
      (BizCode e) => e.code == value,
      orElse: () => BizCode.ok,
    );
  }
}

class BizException with Trace implements Exception {
  @override
  final BizCode code;
  @override
  final String? message;
  @override
  final Object? error;
  @override
  final StackTrace? stack;

  BizException(this.code, this.message, [this.error, this.stack]);

  bool get isTokenExpired => code == BizCode.tokenExpired;
}

/// 业务层 convertor：检测 code，非 0 抛出 BizException
T bizConvertor<T>(dynamic data, T Function(dynamic) dataParser) {
  if (data is Map<String, dynamic>) {
    final int code = data['code'] is int ? data['code'] as int : 0;
    if (code != 0) {
      final String msg = data['message'] as String? ?? '';
      throw BizException(BizCode.fromInt(code), msg);
    }
    return dataParser(data['data']);
  }
  return dataParser(data);
}

void main() {
  late DioAdapter dioAdapter;
  late MockHost host;

  setUp(() {
    host = MockHost();
    FxDio().unregister(host);
    FxDio().register(host, options: const HostOptions(enableLog: false));
    dioAdapter = DioAdapter(dio: FxDio()[host]);
  });

  group('后端业务异常', () {
    test('code=401 token 过期 - convertor 抛出 BizException', () async {
      dioAdapter.onGet(
        '/profile',
        (server) => server.reply(200, {
          'code': 401,
          'message': 'token 已过期，请重新登录',
          'data': null,
        }),
      );

      final ApiRet<String> result = await host.get(
        '/profile',
        convertor: (dynamic data) => bizConvertor<String>(data, (dynamic d) => d.toString()),
      );

      expect(result.failed, isTrue);
      expect(result.msg, 'convert exception');

      // 验证 trace.error 是 BizException
      final Trace trace = (result as ApiFail<String>).trace;
      expect(trace.error, isA<BizException>());

      final BizException bizError = trace.error! as BizException;
      expect(bizError.isTokenExpired, isTrue);
      expect(bizError.message, 'token 已过期，请重新登录');
      expect(bizError.code.code, 401);
    });

    test('code=10001 资源不存在', () async {
      dioAdapter.onGet(
        '/order/999',
        (server) => server.reply(200, {
          'code': 10001,
          'message': '订单不存在',
          'data': null,
        }),
      );

      final ApiRet<Map<String, dynamic>> result = await host.get(
        '/order/999',
        convertor: (dynamic data) =>
            bizConvertor<Map<String, dynamic>>(data, (dynamic d) => d as Map<String, dynamic>),
      );

      expect(result.failed, isTrue);
      final BizException bizError = (result as ApiFail).trace.error! as BizException;
      expect(bizError.code, BizCode.notFound);
      expect(bizError.message, '订单不存在');
    });

    test('code=0 正常返回数据', () async {
      dioAdapter.onGet(
        '/user/1',
        (server) => server.reply(200, {
          'code': 0,
          'message': 'success',
          'data': {'id': 1, 'name': 'Toly'},
        }),
      );

      final ApiRet<Map<String, dynamic>> result = await host.get(
        '/user/1',
        convertor: (dynamic data) =>
            bizConvertor<Map<String, dynamic>>(data, (dynamic d) => d as Map<String, dynamic>),
      );

      expect(result.success, isTrue);
      expect(result.data['name'], 'Toly');
    });

    test('TraceMixin 监听到业务异常', () async {
      dioAdapter.onPost(
        '/pay',
        (server) => server.reply(200, {
          'code': 403,
          'message': '余额不足',
          'data': null,
        }),
      );

      Trace? received;
      FxDio().addTraceListener((Trace trace) => received = trace);

      await host.post(
        '/pay',
        convertor: (dynamic data) => bizConvertor<String>(data, (dynamic d) => d.toString()),
      );

      expect(received, isNotNull);
      expect(received?.error, isA<BizException>());
      final BizException bizError = received!.error! as BizException;
      expect(bizError.code, BizCode.forbidden);
      expect(bizError.message, '余额不足');
    });
  });
}
