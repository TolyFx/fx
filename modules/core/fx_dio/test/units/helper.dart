import 'package:fx_dio/fx_dio.dart';

enum TestEnv { dev, prod }

class TestHost extends RequestHost<TestEnv> {
  @override
  TestEnv get env => TestEnv.dev;

  @override
  Map<TestEnv, String> get value => {
        TestEnv.dev: 'dev.example.com',
        TestEnv.prod: 'api.example.com',
      };
}

class TestHost2 extends RequestHost<TestEnv> {
  @override
  TestEnv get env => TestEnv.prod;

  @override
  Map<TestEnv, String> get value => {
        TestEnv.dev: 'dev2.example.com',
        TestEnv.prod: 'api2.example.com',
      };

  @override
  HostConfig get config => const HostConfig(port: 8080, apiNest: '/api/v1');
}
