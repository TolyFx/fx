import 'package:flutter_test/flutter_test.dart';
import 'package:fx_dao/src/tools/snowflake.dart';

void main() {
  group('SnowflakeIdGenerator', () {
    test('生成唯一 ID', () {
      final SnowflakeIdGenerator gen = SnowflakeIdGenerator(1, 1);
      final Set<int> ids = {};
      for (int i = 0; i < 1000; i++) {
        ids.add(gen.nextId());
      }
      expect(ids.length, 1000);
    });

    test('ID 递增', () {
      final SnowflakeIdGenerator gen = SnowflakeIdGenerator(0, 0);
      int prev = gen.nextId();
      for (int i = 0; i < 100; i++) {
        final int current = gen.nextId();
        expect(current, greaterThan(prev));
        prev = current;
      }
    });

    test('不同 worker 生成不同 ID', () {
      final SnowflakeIdGenerator gen1 = SnowflakeIdGenerator(0, 1);
      final SnowflakeIdGenerator gen2 = SnowflakeIdGenerator(0, 2);
      expect(gen1.nextId(), isNot(gen2.nextId()));
    });

    test('workerId 越界抛异常', () {
      expect(() => SnowflakeIdGenerator(0, 32), throwsA(isA<ArgumentError>()));
      expect(() => SnowflakeIdGenerator(0, -1), throwsA(isA<ArgumentError>()));
    });

    test('datacenterId 越界抛异常', () {
      expect(() => SnowflakeIdGenerator(32, 0), throwsA(isA<ArgumentError>()));
      expect(() => SnowflakeIdGenerator(-1, 0), throwsA(isA<ArgumentError>()));
    });
  });
}
