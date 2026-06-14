import 'package:flutter_test/flutter_test.dart';
import 'package:fx_dio/fx_dio.dart';

class CustomPaginateParser extends PaginateParser {
  const CustomPaginateParser();

  @override
  Paginate? parse(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    final dynamic count = data['count'];
    if (count == null) return null;
    return Paginate(total: count is int ? count : 0);
  }
}

void main() {
  group('DefaultPaginateParser', () {
    const DefaultPaginateParser parser = DefaultPaginateParser();

    test('解析 paginate.total', () {
      final Map<String, dynamic> data = {'paginate': {'total': 50}};
      expect(parser.parse(data)?.total, 50);
    });

    test('解析顶层 total', () {
      final Map<String, dynamic> data = {'total': 30};
      expect(parser.parse(data)?.total, 30);
    });

    test('String 型 total', () {
      final Map<String, dynamic> data = {'total': '25'};
      expect(parser.parse(data)?.total, 25);
    });

    test('无 total 返回 null', () {
      final Map<String, dynamic> data = {'name': 'test'};
      expect(parser.parse(data), isNull);
    });

    test('非 Map 返回 null', () {
      expect(parser.parse('not a map'), isNull);
    });
  });

  group('CustomPaginateParser', () {
    const CustomPaginateParser parser = CustomPaginateParser();

    test('解析 count 字段', () {
      final Map<String, dynamic> data = {'count': 10};
      expect(parser.parse(data)?.total, 10);
    });

    test('无 count 返回 null', () {
      final Map<String, dynamic> data = {'total': 10};
      expect(parser.parse(data), isNull);
    });
  });
}
