import 'package:flutter_test/flutter_test.dart';
import 'package:fx_boot_starter/fx_boot_starter.dart';

class TestConfig {
  final String name;
  const TestConfig(this.name);
}

class TestRepository extends AppStartRepository<TestConfig> {
  final Duration delay;
  final bool shouldFail;

  const TestRepository({
    this.delay = const Duration(milliseconds: 10),
    this.shouldFail = false,
  });

  @override
  Future<TestConfig> initApp() async {
    await Future<void>.delayed(delay);
    if (shouldFail) throw Exception('init failed');
    return const TestConfig('test');
  }
}

class TestAction extends AppStartAction<TestConfig> {
  const TestAction();

  @override
  void onLoaded(_, __, ___) {}

  @override
  void onStartSuccess(_, __) {}

  @override
  void onStartError(_, __, ___) {}
}

void main() {
  group('AppStartBloc', () {
    test('正常启动流：Starting → LoadDone → Success', () async {
      final AppStartBloc<TestConfig> bloc = AppStartBloc<TestConfig>(
        repository: const TestRepository(),
        startAction: const TestAction(),
        minStartDurationMs: 50,
      );

      final List<AppStatus> states = [];
      bloc.stream.listen(states.add);

      bloc.startApp();
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(states.length, 3);
      expect(states[0], isA<AppStarting>());
      expect(states[1], isA<AppLoadDone<TestConfig>>());
      expect(states[2], isA<AppStartSuccess<TestConfig>>());
      expect((states[2] as AppStartSuccess<TestConfig>).data.name, 'test');

      bloc.dispose();
    });

    test('启动失败：Starting → Failed', () async {
      final AppStartBloc<TestConfig> bloc = AppStartBloc<TestConfig>(
        repository: const TestRepository(shouldFail: true),
        startAction: const TestAction(),
        minStartDurationMs: 50,
      );

      final List<AppStatus> states = [];
      bloc.stream.listen(states.add);

      bloc.startApp();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(states.length, 2);
      expect(states[0], isA<AppStarting>());
      expect(states[1], isA<AppStartFailed>());
      expect((states[1] as AppStartFailed).error, isA<Exception>());

      bloc.dispose();
    });

    test('state 保持当前值', () async {
      final AppStartBloc<TestConfig> bloc = AppStartBloc<TestConfig>(
        repository: const TestRepository(),
        startAction: const TestAction(),
        minStartDurationMs: 50,
      );

      expect(bloc.state, isA<AppStarting>());

      bloc.startApp();
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(bloc.state, isA<AppStartSuccess<TestConfig>>());

      bloc.dispose();
    });
  });
}
