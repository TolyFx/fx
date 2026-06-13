import 'package:flutter_test/flutter_test.dart';
import 'package:fx_dio/fx_dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import 'helper.dart';

class CountParser extends PaginateParser {
  const CountParser();

  @override
  Paginate? parse(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    final dynamic count = data['count'];
    if (count == null) return null;
    return Paginate(total: count is int ? count : 0);
  }
}

void main() {
  late MockHost host1;
  late MockHost2 host2;
  late DioAdapter adapter1;
  late DioAdapter adapter2;

  setUp(() {
    host1 = MockHost();
    host2 = MockHost2();
    FxDio().unregister(host1);
    FxDio().unregister(host2);
    FxDio().register(host1, options: const HostOptions(enableLog: false));
    FxDio().register(
      host2,
      options: const HostOptions(
        enableLog: false,
        paginateParser: CountParser(),
      ),
    );
    adapter1 = DioAdapter(dio: FxDio()[host1]);
    adapter2 = DioAdapter(dio: FxDio()[host2]);
  });

  group('多 Host 隔离', () {
    test('不同 Host 使用各自的 PaginateParser', () async {
      adapter1.onGet(
        '/items',
        (server) => server.reply(200, {
          'list': [1, 2],
          'total': 50,
        }),
      );

      adapter2.onGet(
        '/items',
        (server) => server.reply(200, {
          'list': [3, 4],
          'count': 80,
        }),
      );

      final ApiRet<List<dynamic>> result1 = await host1.get(
        '/items',
        convertor: (dynamic data) =>
            (data as Map<String, dynamic>)['list'] as List<dynamic>,
      );

      final ApiRet<List<dynamic>> result2 = await host2.get(
        '/items',
        convertor: (dynamic data) =>
            (data as Map<String, dynamic>)['list'] as List<dynamic>,
      );

      // host1 用 DefaultPaginateParser → 取 total
      expect(result1.paginate?.total, 50);
      // host2 用 CountParser → 取 count
      expect(result2.paginate?.total, 80);
    });
  });
}
