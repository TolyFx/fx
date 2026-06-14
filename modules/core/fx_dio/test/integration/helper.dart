import 'package:fx_dio/fx_dio.dart';

enum TestEnv { dev, prod }

class MockHost extends RequestHost<TestEnv> {
  @override
  TestEnv get env => TestEnv.dev;

  @override
  Map<TestEnv, String> get value => {
        TestEnv.dev: 'https://mock.example.com',
        TestEnv.prod: 'https://api.example.com',
      };

  @override
  HostConfig get config => const HostConfig(scheme: 'https');
}

class MockHost2 extends RequestHost<TestEnv> {
  @override
  TestEnv get env => TestEnv.dev;

  @override
  Map<TestEnv, String> get value => {
        TestEnv.dev: 'https://mock2.example.com',
        TestEnv.prod: 'https://api2.example.com',
      };
}
